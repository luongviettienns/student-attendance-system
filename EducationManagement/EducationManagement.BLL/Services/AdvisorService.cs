using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EducationManagement.Common.DTOs.Advisor;
using EducationManagement.DAL.Repositories;
using System.Linq;
using Microsoft.Extensions.Configuration;

namespace EducationManagement.BLL.Services
{
    public class AdvisorService
    {
        private readonly AdvisorRepository _advisorRepository;
        private readonly EmailService _emailService;
        private readonly IConfiguration _configuration;
        private readonly RetakeService? _retakeService;
        private readonly EnrollmentRepository? _enrollmentRepository;

        public AdvisorService(AdvisorRepository advisorRepository, EmailService emailService, 
            IConfiguration configuration, RetakeService? retakeService = null, 
            EnrollmentRepository? enrollmentRepository = null)
        {
            _advisorRepository = advisorRepository;
            _emailService = emailService;
            _configuration = configuration;
            _retakeService = retakeService;
            _enrollmentRepository = enrollmentRepository;
        }

        /// <summary>
        /// Get dashboard statistics with filters
        /// Advisor (Cố vấn phòng đào tạo) quản lý CHUNG TOÀN BỘ sinh viên của trường.
        /// Không filter theo advisor_id, chỉ filter theo Faculty, Major, Class (optional).
        /// Nếu không có filter, trả về thống kê toàn trường.
        /// </summary>
        public async Task<AdvisorDashboardStatsDto> GetDashboardStatsAsync(StudentFiltersDto? filters)
        {
            try
            {
                return await _advisorRepository.GetDashboardStatsAsync(
                    filters?.FacultyId,
                    filters?.MajorId,
                    filters?.ClassId
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting dashboard stats: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get warning students with filters
        /// Advisor có thể xem cảnh báo của TOÀN BỘ sinh viên (không filter theo advisor_id).
        /// Filter theo Faculty, Major, Class là optional để xem chi tiết.
        /// </summary>
        public async Task<(List<WarningStudentDto> Students, int TotalCount)> GetWarningStudentsAsync(
            int page = 1, int pageSize = 20, StudentFiltersDto? filters = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            try
            {
                return await _advisorRepository.GetWarningStudentsAsync(
                    page, pageSize,
                    filters?.FacultyId,
                    filters?.MajorId,
                    filters?.ClassId
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting warning students: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student detail with academic summary
        /// </summary>
        public async Task<AdvisorStudentDetailDto?> GetStudentDetailAsync(string studentId)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            try
            {
                return await _advisorRepository.GetStudentDetailAsync(studentId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student detail: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student grades with filters (mandatory filter validation)
        /// </summary>
        public async Task<(List<AdvisorStudentGradeDto> Grades, AdvisorStudentGradesSummaryDto Summary)> GetStudentGradesAsync(
            string studentId,
            string? schoolYearId = null,
            int? semester = null,
            string? subjectId = null)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            // Mandatory filter validation: at least one filter must be provided
            if (string.IsNullOrEmpty(schoolYearId) && semester == null && string.IsNullOrEmpty(subjectId))
            {
                throw new ArgumentException(
                    "Filter is required. Please provide at least one filter (schoolYearId, semester, or subjectId)",
                    nameof(schoolYearId));
            }

            try
            {
                return await _advisorRepository.GetStudentGradesAsync(studentId, schoolYearId, semester, subjectId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student grades: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student attendance with filters (mandatory filter validation)
        /// </summary>
        public async Task<AdvisorStudentAttendanceResponseDto> GetStudentAttendanceAsync(
            string studentId,
            string? schoolYearId = null,
            int? semester = null,
            string? subjectId = null)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            // Mandatory filter validation: at least one filter must be provided
            if (string.IsNullOrEmpty(schoolYearId) && semester == null && string.IsNullOrEmpty(subjectId))
            {
                throw new ArgumentException(
                    "Filter is required. Please provide at least one filter (schoolYearId, semester, or subjectId)",
                    nameof(schoolYearId));
            }

            try
            {
                return await _advisorRepository.GetStudentAttendanceAsync(studentId, schoolYearId, semester, subjectId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student attendance: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get students list with filters (mandatory filter validation for performance)
        /// Advisor có thể xem TOÀN BỘ sinh viên, nhưng cần ít nhất 1 filter để tránh load quá nhiều data.
        /// Filter có thể là: Faculty, Major, Class, Cohort Year, Search, Warning Status, GPA range, Attendance rate.
        /// </summary>
        public async Task<(List<WarningStudentDto> Students, int TotalCount)> GetStudentsAsync(
            int page = 1,
            int pageSize = 20,
            StudentFiltersDto? filters = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            // Mandatory filter validation: at least one filter must be provided
            if (filters == null ||
                (string.IsNullOrEmpty(filters.FacultyId) &&
                 string.IsNullOrEmpty(filters.MajorId) &&
                 string.IsNullOrEmpty(filters.ClassId) &&
                 string.IsNullOrEmpty(filters.CohortYear) &&
                 string.IsNullOrEmpty(filters.Search) &&
                 string.IsNullOrEmpty(filters.WarningStatus) &&
                 !filters.GpaMin.HasValue &&
                 !filters.GpaMax.HasValue &&
                 !filters.AttendanceRateMin.HasValue &&
                 !filters.AttendanceRateMax.HasValue))
            {
                throw new ArgumentException(
                    "Filter is required. Please provide at least one filter (faculty, major, class, cohort, search, warningStatus, gpa, or attendanceRate)",
                    nameof(filters));
            }

            try
            {
                return await _advisorRepository.GetStudentsAsync(
                    page,
                    pageSize,
                    filters.Search,
                    filters.FacultyId,
                    filters.MajorId,
                    filters.ClassId,
                    filters.CohortYear,
                    filters.WarningStatus,
                    filters.GpaMin,
                    filters.GpaMax,
                    filters.AttendanceRateMin,
                    filters.AttendanceRateMax
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting students: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student GPA progress by semester
        /// </summary>
        public async Task<StudentGpaProgressDto?> GetStudentGpaProgressAsync(string studentId, string? schoolYearId = null)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            try
            {
                return await _advisorRepository.GetStudentGpaProgressAsync(studentId, schoolYearId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student GPA progress: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student attendance progress by semester
        /// </summary>
        public async Task<StudentAttendanceProgressDto?> GetStudentAttendanceProgressAsync(string studentId, string? schoolYearId = null)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            try
            {
                return await _advisorRepository.GetStudentAttendanceProgressAsync(studentId, schoolYearId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student attendance progress: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get student trends and alerts
        /// </summary>
        public async Task<StudentTrendsDto?> GetStudentTrendsAsync(string studentId)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            try
            {
                return await _advisorRepository.GetStudentTrendsAsync(studentId);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting student trends: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get attendance warnings
        /// </summary>
        public async Task<(List<AttendanceWarningDto> Warnings, int TotalCount)> GetAttendanceWarningsAsync(
            int page = 1,
            int pageSize = 100,
            decimal? attendanceThreshold = null,
            StudentFiltersDto? filters = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            // Get threshold from config or use default
            var threshold = attendanceThreshold ?? 
                decimal.Parse(_configuration["Advisor:WarningThresholds:Attendance"] ?? "20.0");

            try
            {
                return await _advisorRepository.GetAttendanceWarningsAsync(
                    page,
                    pageSize,
                    threshold,
                    filters?.FacultyId,
                    filters?.MajorId,
                    filters?.ClassId,
                    filters?.CohortYear
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting attendance warnings: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Get academic warnings
        /// </summary>
        public async Task<(List<AcademicWarningDto> Warnings, int TotalCount)> GetAcademicWarningsAsync(
            int page = 1,
            int pageSize = 100,
            decimal? gpaThreshold = null,
            StudentFiltersDto? filters = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            // Get threshold from config or use default
            var threshold = gpaThreshold ?? 
                decimal.Parse(_configuration["Advisor:WarningThresholds:Gpa"] ?? "2.0");

            try
            {
                return await _advisorRepository.GetAcademicWarningsAsync(
                    page,
                    pageSize,
                    threshold,
                    filters?.FacultyId,
                    filters?.MajorId,
                    filters?.ClassId,
                    filters?.CohortYear
                );
            }
            catch (Exception ex)
            {
                throw new Exception($"Error getting academic warnings: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Send warning email to a student
        /// </summary>
        public async Task SendWarningEmailAsync(string studentId, string warningType, string? customSubject = null, string? customMessage = null)
        {
            if (string.IsNullOrEmpty(studentId))
            {
                throw new ArgumentException("Student ID is required", nameof(studentId));
            }

            if (string.IsNullOrEmpty(warningType))
            {
                throw new ArgumentException("Warning type is required", nameof(warningType));
            }

            try
            {
                var studentInfo = await _advisorRepository.GetStudentInfoForEmailAsync(studentId);
                if (studentInfo == null)
                {
                    throw new Exception("Student not found");
                }

                var (email, fullName, className, gpa, absenceRate) = studentInfo.Value;

                if (string.IsNullOrEmpty(email))
                {
                    throw new Exception("Student email not found");
                }

                className ??= "N/A";

                switch (warningType.ToLower())
                {
                    case "attendance":
                        if (!absenceRate.HasValue)
                        {
                            throw new Exception("Absence rate not available for student");
                        }
                        await _emailService.SendAttendanceWarningEmailAsync(
                            email, fullName, className, absenceRate.Value, customSubject, customMessage);
                        break;

                    case "academic":
                        if (!gpa.HasValue)
                        {
                            throw new Exception("GPA not available for student");
                        }
                        await _emailService.SendAcademicWarningAsync(
                            email, fullName, className, gpa.Value, customSubject, customMessage);
                        break;

                    case "both":
                        if (!gpa.HasValue || !absenceRate.HasValue)
                        {
                            throw new Exception("GPA or absence rate not available for student");
                        }
                        await _emailService.SendBothWarningEmailAsync(
                            email, fullName, className, gpa.Value, absenceRate.Value, customSubject, customMessage);
                        break;

                    default:
                        throw new ArgumentException($"Invalid warning type: {warningType}", nameof(warningType));
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Error sending warning email: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// Send bulk warning emails
        /// </summary>
        public async Task SendBulkWarningEmailAsync(List<string> studentIds, string warningType, string? customSubject = null, string? customMessage = null)
        {
            if (studentIds == null || studentIds.Count == 0)
            {
                throw new ArgumentException("Student IDs are required", nameof(studentIds));
            }

            if (string.IsNullOrEmpty(warningType))
            {
                throw new ArgumentException("Warning type is required", nameof(warningType));
            }

            var errors = new List<string>();

            foreach (var studentId in studentIds)
            {
                try
                {
                    await SendWarningEmailAsync(studentId, warningType, customSubject, customMessage);
                }
                catch (Exception ex)
                {
                    errors.Add($"Student {studentId}: {ex.Message}");
                }
            }

            if (errors.Count > 0)
            {
                throw new Exception($"Some emails failed to send: {string.Join("; ", errors)}");
            }
        }

        /// <summary>
        /// Get warning configuration
        /// </summary>
        public Task<WarningConfigDto> GetWarningConfigAsync()
        {
            var config = new WarningConfigDto
            {
                AttendanceThreshold = decimal.Parse(_configuration["Advisor:WarningThresholds:Attendance"] ?? "20.0"),
                GpaThreshold = decimal.Parse(_configuration["Advisor:WarningThresholds:Gpa"] ?? "2.0"),
                EmailTemplate = _configuration["Advisor:Email:Template"],
                EmailSubject = _configuration["Advisor:Email:Subject"],
                AutoSendEmails = bool.Parse(_configuration["Advisor:Email:AutoSend"] ?? "false")
            };
            return Task.FromResult(config);
        }

        /// <summary>
        /// Update warning configuration (saved to appsettings.json - requires app restart)
        /// Note: In production, consider using a database table for configuration
        /// </summary>
        public async Task UpdateWarningConfigAsync(WarningConfigDto config)
        {
            // Note: This is a simplified implementation
            // In production, you should save to a database table
            // For now, we'll just validate the configuration
            if (config.AttendanceThreshold < 0 || config.AttendanceThreshold > 100)
            {
                throw new ArgumentException("Attendance threshold must be between 0 and 100", nameof(config));
            }

            if (config.GpaThreshold < 0 || config.GpaThreshold > 10)
            {
                throw new ArgumentException("GPA threshold must be between 0 and 10", nameof(config));
            }

            // In a real implementation, you would update the configuration file or database
            // For now, we'll just return success after validation
            await Task.CompletedTask;
        }

        /// <summary>
        /// Check and send warning after attendance is marked (Event-Driven)
        /// Called automatically when attendance is created
        /// </summary>
        public async Task CheckAndSendWarningAfterAttendance(string studentId, string classId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                return;

            if (string.IsNullOrWhiteSpace(classId))
                return;

            try
            {
                // 1. Get absence rate for this student in this class
                var absenceRate = await _advisorRepository.GetStudentAbsenceRateByClassAsync(studentId, classId);
                
                if (!absenceRate.HasValue)
                    return; // No attendance data yet

                // 2. Get threshold from config (default 20%)
                var threshold = decimal.Parse(_configuration["Advisor:WarningThresholds:Attendance"] ?? "20.0");
                var minDaysBetweenWarnings = int.Parse(_configuration["Advisor:WarningSettings:MinDaysBetweenWarnings"] ?? "7");

                // 3. Check if exceeds threshold
                if (absenceRate.Value > threshold)
                {
                    // 4. Check last warning sent (avoid spam)
                    var lastWarning = await _advisorRepository.GetLastWarningSentAsync(studentId);
                    var shouldSend = lastWarning == null || 
                                    lastWarning.Value < DateTime.Now.AddDays(-minDaysBetweenWarnings);

                    if (shouldSend)
                    {
                        // 5. Get student info
                        var studentInfo = await _advisorRepository.GetStudentInfoForEmailAsync(studentId);
                        if (studentInfo.HasValue)
                        {
                            var (email, fullName, className, gpa, _) = studentInfo.Value;

                            if (!string.IsNullOrEmpty(email))
                            {
                                // 6. Send warning email
                                await _emailService.SendAttendanceWarningEmailAsync(
                                    email,
                                    fullName,
                                    className ?? "N/A",
                                    absenceRate.Value
                                );

                                // 7. Update last warning sent
                                await _advisorRepository.UpdateLastWarningSentAsync(studentId);

                                // 8. ✅ Auto-create retake record if absence rate > threshold
                                if (_retakeService != null && _enrollmentRepository != null)
                                {
                                    try
                                    {
                                        // Get enrollment_id from studentId and classId
                                        var enrollments = await _enrollmentRepository.GetByStudentIdAsync(studentId);
                                        var enrollment = enrollments.FirstOrDefault(e => e.ClassId == classId && 
                                            e.EnrollmentStatus == "APPROVED" && e.DeletedAt == null);
                                        
                                        if (enrollment != null)
                                        {
                                            // Trigger retake check (async, don't wait)
                                            _ = Task.Run(async () =>
                                            {
                                                try
                                                {
                                                    await _retakeService.CheckAndCreateRetakeAsync(enrollment.EnrollmentId);
                                                }
                                                catch (Exception ex2)
                                                {
                                                    Console.WriteLine($"Warning: Failed to check retake after warning: {ex2.Message}");
                                                }
                                            });
                                        }
                                    }
                                    catch (Exception ex2)
                                    {
                                        Console.WriteLine($"Warning: Failed to get enrollment for retake check: {ex2.Message}");
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error but don't fail the attendance creation
                // In production, use proper logging (ILogger)
                Console.WriteLine($"Warning: Failed to check/send warning after attendance: {ex.Message}");
            }
        }
    }
}

