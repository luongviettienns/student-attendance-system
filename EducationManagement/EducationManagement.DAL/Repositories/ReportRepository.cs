using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.DTOs.Report;

namespace EducationManagement.DAL.Repositories
{
    public class ReportRepository
    {
        private readonly string _connectionString;

        public ReportRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        /// <summary>
        /// Get admin reports data
        /// </summary>
        public async Task<AdminReportDto> GetAdminReportAsync(
            string? schoolYearId = null,
            int? semester = null,
            string? facultyId = null,
            string? majorId = null)
        {
            var report = new AdminReportDto();

            // 1. Credit Debt Stats
            var creditDebtStats = await GetCreditDebtStatsAsync(schoolYearId, semester, facultyId, majorId);
            report.CreditDebtStats = creditDebtStats;

            // 2. Academic Warnings
            var academicWarnings = await GetAcademicWarningsAsync(schoolYearId, semester, facultyId, majorId);
            report.AcademicWarnings = academicWarnings;

            // 3. GPA Distribution
            var gpaDistribution = await GetGpaDistributionAsync(schoolYearId, semester, facultyId, majorId);
            report.GpaDistribution = gpaDistribution;

            // 4. Top 10 Credit Debt Students
            var topCreditDebt = await GetTopCreditDebtStudentsAsync(schoolYearId, semester, facultyId, majorId);
            report.TopCreditDebt = topCreditDebt;

            return report;
        }

        private async Task<CreditDebtStatsDto> GetCreditDebtStatsAsync(
            string? schoolYearId,
            int? semester,
            string? facultyId,
            string? majorId)
        {
            var stats = new CreditDebtStatsDto();
            var ranges = new List<CreditDebtRangeDto>();

            var sql = @"
                WITH StudentCredits AS (
                    SELECT 
                        s.student_id,
                        120 as required_credits, -- Default required credits (majors table doesn't have this column)
                        COALESCE(SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END), 0) as earned_credits
                    FROM dbo.students s
                    LEFT JOIN dbo.majors m ON s.major_id = m.major_id
                    LEFT JOIN dbo.enrollments e ON s.student_id = e.student_id AND e.deleted_at IS NULL
                    LEFT JOIN dbo.classes c ON e.class_id = c.class_id AND c.deleted_at IS NULL
                    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
                    LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
                    WHERE s.deleted_at IS NULL
                        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
                        AND (@Semester IS NULL OR c.semester = @Semester)
                        AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
                        AND (@MajorId IS NULL OR s.major_id = @MajorId)
                    GROUP BY s.student_id
                )
                SELECT 
                    student_id,
                    required_credits - earned_credits as credit_debt
                FROM StudentCredits
                WHERE required_credits - earned_credits > 0";

            var parameters = new[]
            {
                new SqlParameter("@SchoolYearId", (object?)schoolYearId ?? DBNull.Value),
                new SqlParameter("@Semester", (object?)semester ?? DBNull.Value),
                new SqlParameter("@FacultyId", (object?)facultyId ?? DBNull.Value),
                new SqlParameter("@MajorId", (object?)majorId ?? DBNull.Value)
            };

            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            using var reader = await cmd.ExecuteReaderAsync();

            var debts = new List<int>();
            while (await reader.ReadAsync())
            {
                var debt = reader["credit_debt"] != DBNull.Value ? Convert.ToInt32(reader["credit_debt"]) : 0;
                if (debt > 0)
                    debts.Add(debt);
            }

            stats.Total = debts.Count;

            // Group by ranges: 0-10, 11-20, 21-30, 31-40, 41-50, 50+
            var rangeGroups = new Dictionary<string, int>
            {
                ["0-10"] = 0,
                ["11-20"] = 0,
                ["21-30"] = 0,
                ["31-40"] = 0,
                ["41-50"] = 0,
                ["50+"] = 0
            };

            foreach (var debt in debts)
            {
                if (debt <= 10) rangeGroups["0-10"]++;
                else if (debt <= 20) rangeGroups["11-20"]++;
                else if (debt <= 30) rangeGroups["21-30"]++;
                else if (debt <= 40) rangeGroups["31-40"]++;
                else if (debt <= 50) rangeGroups["41-50"]++;
                else rangeGroups["50+"]++;
            }

            foreach (var kvp in rangeGroups)
            {
                if (kvp.Value > 0)
                {
                    ranges.Add(new CreditDebtRangeDto { Range = kvp.Key, Count = kvp.Value });
                }
            }

            stats.ByRange = ranges;
            return stats;
        }

        private async Task<AcademicWarningsDto> GetAcademicWarningsAsync(
            string? schoolYearId,
            int? semester,
            string? facultyId,
            string? majorId)
        {
            var warnings = new AcademicWarningsDto();

            var sql = @"
                WITH StudentStats AS (
                    SELECT 
                        s.student_id,
                        -- GPA calculation
                        COALESCE(
                            (SELECT TOP 1 gpa4 FROM dbo.gpas WHERE student_id = s.student_id AND deleted_at IS NULL ORDER BY created_at DESC, semester DESC),
                            CASE 
                                WHEN SUM(sub.credits) > 0 
                                THEN ROUND(SUM(
                                    CASE 
                                        WHEN g.total_score >= 9.0 THEN 4.0
                                        WHEN g.total_score >= 8.5 THEN 3.7
                                        WHEN g.total_score >= 8.0 THEN 3.5
                                        WHEN g.total_score >= 7.0 THEN 3.0
                                        WHEN g.total_score >= 6.5 THEN 2.5
                                        WHEN g.total_score >= 6.0 THEN 2.0
                                        WHEN g.total_score >= 5.5 THEN 1.5
                                        WHEN g.total_score >= 5.0 THEN 1.0
                                        WHEN g.total_score >= 4.0 THEN 0.5
                                        ELSE 0
                                    END * sub.credits
                                ) / NULLIF(SUM(sub.credits), 0), 2)
                                ELSE 0
                            END,
                            0
                        ) as gpa,
                        -- Attendance rate
                        CASE 
                            WHEN COUNT(a.attendance_id) > 0 
                            THEN (COUNT(CASE WHEN a.status IN ('Present', 'Late', 'Excused') THEN 1 END) * 100.0 / COUNT(a.attendance_id))
                            ELSE 100
                        END as attendance_rate
                    FROM dbo.students s
                    LEFT JOIN dbo.enrollments e ON s.student_id = e.student_id AND e.deleted_at IS NULL
                    LEFT JOIN dbo.classes c ON e.class_id = c.class_id AND c.deleted_at IS NULL
                    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
                    LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
                    LEFT JOIN dbo.attendances a ON e.enrollment_id = a.enrollment_id AND a.deleted_at IS NULL
                    WHERE s.deleted_at IS NULL
                        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
                        AND (@Semester IS NULL OR c.semester = @Semester)
                        AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
                        AND (@MajorId IS NULL OR s.major_id = @MajorId)
                    GROUP BY s.student_id
                )
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN gpa < 2.0 AND attendance_rate >= 50 THEN 1 ELSE 0 END) as low_gpa,
                    SUM(CASE WHEN gpa >= 2.0 AND attendance_rate < 50 THEN 1 ELSE 0 END) as poor_attendance,
                    SUM(CASE WHEN gpa < 2.0 AND attendance_rate < 50 THEN 1 ELSE 0 END) as both
                FROM StudentStats
                WHERE gpa < 2.0 OR attendance_rate < 50";

            var parameters = new[]
            {
                new SqlParameter("@SchoolYearId", (object?)schoolYearId ?? DBNull.Value),
                new SqlParameter("@Semester", (object?)semester ?? DBNull.Value),
                new SqlParameter("@FacultyId", (object?)facultyId ?? DBNull.Value),
                new SqlParameter("@MajorId", (object?)majorId ?? DBNull.Value)
            };

            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            using var reader = await cmd.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                warnings.Total = reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0;
                warnings.LowGpa = reader["low_gpa"] != DBNull.Value ? Convert.ToInt32(reader["low_gpa"]) : 0;
                warnings.PoorAttendance = reader["poor_attendance"] != DBNull.Value ? Convert.ToInt32(reader["poor_attendance"]) : 0;
                warnings.Both = reader["both"] != DBNull.Value ? Convert.ToInt32(reader["both"]) : 0;
            }

            return warnings;
        }

        private async Task<GpaDistributionDto> GetGpaDistributionAsync(
            string? schoolYearId,
            int? semester,
            string? facultyId,
            string? majorId)
        {
            var distribution = new GpaDistributionDto();

            var sql = @"
                WITH StudentGPA AS (
                    SELECT 
                        s.student_id,
                        COALESCE(
                            (SELECT TOP 1 gpa4 FROM dbo.gpas WHERE student_id = s.student_id AND deleted_at IS NULL ORDER BY created_at DESC, semester DESC),
                            CASE 
                                WHEN SUM(sub.credits) > 0 
                                THEN ROUND(SUM(
                                    CASE 
                                        WHEN g.total_score >= 9.0 THEN 4.0
                                        WHEN g.total_score >= 8.5 THEN 3.7
                                        WHEN g.total_score >= 8.0 THEN 3.5
                                        WHEN g.total_score >= 7.0 THEN 3.0
                                        WHEN g.total_score >= 6.5 THEN 2.5
                                        WHEN g.total_score >= 6.0 THEN 2.0
                                        WHEN g.total_score >= 5.5 THEN 1.5
                                        WHEN g.total_score >= 5.0 THEN 1.0
                                        WHEN g.total_score >= 4.0 THEN 0.5
                                        ELSE 0
                                    END * sub.credits
                                ) / NULLIF(SUM(sub.credits), 0), 2)
                                ELSE 0
                            END,
                            0
                        ) as gpa
                    FROM dbo.students s
                    LEFT JOIN dbo.enrollments e ON s.student_id = e.student_id AND e.deleted_at IS NULL
                    LEFT JOIN dbo.classes c ON e.class_id = c.class_id AND c.deleted_at IS NULL
                    LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
                    LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
                    WHERE s.deleted_at IS NULL
                        AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
                        AND (@Semester IS NULL OR c.semester = @Semester)
                        AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
                        AND (@MajorId IS NULL OR s.major_id = @MajorId)
                    GROUP BY s.student_id
                )
                SELECT 
                    SUM(CASE WHEN gpa >= 3.5 THEN 1 ELSE 0 END) as excellent,
                    SUM(CASE WHEN gpa >= 3.0 AND gpa < 3.5 THEN 1 ELSE 0 END) as good,
                    SUM(CASE WHEN gpa >= 2.0 AND gpa < 3.0 THEN 1 ELSE 0 END) as average,
                    SUM(CASE WHEN gpa < 2.0 THEN 1 ELSE 0 END) as weak
                FROM StudentGPA";

            var parameters = new[]
            {
                new SqlParameter("@SchoolYearId", (object?)schoolYearId ?? DBNull.Value),
                new SqlParameter("@Semester", (object?)semester ?? DBNull.Value),
                new SqlParameter("@FacultyId", (object?)facultyId ?? DBNull.Value),
                new SqlParameter("@MajorId", (object?)majorId ?? DBNull.Value)
            };

            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            using var reader = await cmd.ExecuteReaderAsync();

            if (await reader.ReadAsync())
            {
                distribution.Excellent = reader["excellent"] != DBNull.Value ? Convert.ToInt32(reader["excellent"]) : 0;
                distribution.Good = reader["good"] != DBNull.Value ? Convert.ToInt32(reader["good"]) : 0;
                distribution.Average = reader["average"] != DBNull.Value ? Convert.ToInt32(reader["average"]) : 0;
                distribution.Weak = reader["weak"] != DBNull.Value ? Convert.ToInt32(reader["weak"]) : 0;
            }

            return distribution;
        }

        private async Task<List<TopCreditDebtStudentDto>> GetTopCreditDebtStudentsAsync(
            string? schoolYearId,
            int? semester,
            string? facultyId,
            string? majorId)
        {
            var students = new List<TopCreditDebtStudentDto>();

            var sql = @"
                SELECT TOP 10
                    s.student_id,
                    s.student_code,
                    s.full_name,
                    ac.class_name,
                    f.faculty_name,
                    m.major_name,
                    120 as required_credits, -- Default required credits (majors table doesn't have this column)
                    COALESCE(SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END), 0) as earned_credits,
                    120 - COALESCE(SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END), 0) as credit_debt
                FROM dbo.students s
                LEFT JOIN dbo.majors m ON s.major_id = m.major_id
                LEFT JOIN dbo.faculties f ON s.faculty_id = f.faculty_id
                LEFT JOIN dbo.administrative_classes ac ON s.admin_class_id = ac.admin_class_id
                LEFT JOIN dbo.enrollments e ON s.student_id = e.student_id AND e.deleted_at IS NULL
                LEFT JOIN dbo.classes c ON e.class_id = c.class_id AND c.deleted_at IS NULL
                LEFT JOIN dbo.subjects sub ON c.subject_id = sub.subject_id
                LEFT JOIN dbo.grades g ON e.enrollment_id = g.enrollment_id
                WHERE s.deleted_at IS NULL
                    AND (@SchoolYearId IS NULL OR c.school_year_id = @SchoolYearId)
                    AND (@Semester IS NULL OR c.semester = @Semester)
                    AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
                    AND (@MajorId IS NULL OR s.major_id = @MajorId)
                GROUP BY s.student_id, s.student_code, s.full_name, ac.class_name, f.faculty_name, m.major_name
                HAVING 120 - COALESCE(SUM(CASE WHEN g.total_score >= 5.0 THEN sub.credits ELSE 0 END), 0) > 0
                ORDER BY credit_debt DESC";

            var parameters = new[]
            {
                new SqlParameter("@SchoolYearId", (object?)schoolYearId ?? DBNull.Value),
                new SqlParameter("@Semester", (object?)semester ?? DBNull.Value),
                new SqlParameter("@FacultyId", (object?)facultyId ?? DBNull.Value),
                new SqlParameter("@MajorId", (object?)majorId ?? DBNull.Value)
            };

            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddRange(parameters);
            using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                students.Add(new TopCreditDebtStudentDto
                {
                    StudentId = reader["student_id"].ToString() ?? string.Empty,
                    StudentCode = reader["student_code"].ToString() ?? string.Empty,
                    FullName = reader["full_name"].ToString() ?? string.Empty,
                    ClassName = reader["class_name"]?.ToString(),
                    FacultyName = reader["faculty_name"]?.ToString(),
                    MajorName = reader["major_name"]?.ToString(),
                    TotalCreditsRequired = reader["required_credits"] != DBNull.Value ? Convert.ToInt32(reader["required_credits"]) : 120,
                    TotalCreditsEarned = reader["earned_credits"] != DBNull.Value ? Convert.ToInt32(reader["earned_credits"]) : 0,
                    CreditDebt = reader["credit_debt"] != DBNull.Value ? Convert.ToInt32(reader["credit_debt"]) : 0
                });
            }

            return students;
        }
    }
}
