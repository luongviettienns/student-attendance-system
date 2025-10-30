using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;
using EducationManagement.Common.DTOs.RegistrationPeriod;

namespace EducationManagement.DAL.Repositories
{
    public class RegistrationPeriodRepository
    {
        private readonly string _connectionString;

        public RegistrationPeriodRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        // ============================================================
        // 1️⃣ GET ALL
        // ============================================================
        public async Task<List<PeriodDetailDto>> GetAllAsync()
        {
            var dt = await DatabaseHelper.ExecuteQueryAsync(
                _connectionString, "sp_GetAllRegistrationPeriods", Array.Empty<SqlParameter>());

            var periods = new List<PeriodDetailDto>();
            foreach (DataRow row in dt.Rows)
            {
                periods.Add(MapToPeriodDetailDto(row));
            }

            return periods;
        }

        // ============================================================
        // 2️⃣ GET BY ID
        // ============================================================
        public async Task<PeriodDetailDto?> GetByIdAsync(string periodId)
        {
            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId)
            };

            var dt = await DatabaseHelper.ExecuteQueryAsync(
                _connectionString, "sp_GetRegistrationPeriodById", parameters);

            if (dt.Rows.Count == 0)
                return null;

            return MapToPeriodDetailDto(dt.Rows[0]);
        }

        // ============================================================
        // 3️⃣ GET ACTIVE PERIOD
        // ============================================================
        public async Task<PeriodDetailDto?> GetActiveAsync()
        {
            var dt = await DatabaseHelper.ExecuteQueryAsync(
                _connectionString, "sp_GetCurrentRegistrationPeriod", Array.Empty<SqlParameter>());

            if (dt.Rows.Count == 0)
                return null;

            return MapToPeriodDetailDto(dt.Rows[0]);
        }

        // ============================================================
        // 4️⃣ CREATE
        // ============================================================
        public async Task<string> CreateAsync(CreatePeriodDto dto, string createdBy)
        {
            string periodId = $"RP-{Guid.NewGuid()}";

            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId),
                new SqlParameter("@PeriodName", dto.PeriodName),
                new SqlParameter("@AcademicYearId", dto.AcademicYearId),
                new SqlParameter("@Semester", dto.Semester),
                new SqlParameter("@StartDate", dto.StartDate),
                new SqlParameter("@EndDate", dto.EndDate),
                new SqlParameter("@Description", (object?)dto.Description ?? DBNull.Value),
                new SqlParameter("@CreatedBy", createdBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(
                _connectionString, "sp_CreateRegistrationPeriod", parameters);

            return periodId;
        }

        // ============================================================
        // 5️⃣ UPDATE
        // ============================================================
        public async Task UpdateAsync(string periodId, UpdatePeriodDto dto, string updatedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId),
                new SqlParameter("@PeriodName", dto.PeriodName),
                new SqlParameter("@AcademicYearId", dto.AcademicYearId),
                new SqlParameter("@Semester", dto.Semester),
                new SqlParameter("@StartDate", dto.StartDate),
                new SqlParameter("@EndDate", dto.EndDate),
                new SqlParameter("@Description", (object?)dto.Description ?? DBNull.Value),
                new SqlParameter("@UpdatedBy", updatedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(
                _connectionString, "sp_UpdateRegistrationPeriod", parameters);
        }

        // ============================================================
        // 6️⃣ DELETE (Soft Delete)
        // ============================================================
        public async Task DeleteAsync(string periodId, string deletedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId),
                new SqlParameter("@DeletedBy", deletedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(
                _connectionString, "sp_DeleteRegistrationPeriod", parameters);
        }

        // ============================================================
        // 7️⃣ OPEN PERIOD
        // ============================================================
        public async Task OpenPeriodAsync(string periodId, string openedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId),
                new SqlParameter("@OpenedBy", openedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(
                _connectionString, "sp_OpenRegistrationPeriod", parameters);
        }

        // ============================================================
        // 8️⃣ CLOSE PERIOD
        // ============================================================
        public async Task ClosePeriodAsync(string periodId, string closedBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@PeriodId", periodId),
                new SqlParameter("@ClosedBy", closedBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(
                _connectionString, "sp_CloseRegistrationPeriod", parameters);
        }

        // ============================================================
        // MAPPING HELPER
        // ============================================================
        private static PeriodDetailDto MapToPeriodDetailDto(DataRow row)
        {
            return new PeriodDetailDto
            {
                PeriodId = row["period_id"].ToString()!,
                PeriodName = row["period_name"].ToString()!,
                AcademicYearId = row["academic_year_id"].ToString()!,
                AcademicYearName = row["academic_year_name"]?.ToString(),
                StartYear = row.Table.Columns.Contains("start_year") && row["start_year"] != DBNull.Value 
                    ? Convert.ToInt32(row["start_year"]) : null,
                EndYear = row.Table.Columns.Contains("end_year") && row["end_year"] != DBNull.Value 
                    ? Convert.ToInt32(row["end_year"]) : null,
                Semester = Convert.ToInt32(row["semester"]),
                StartDate = Convert.ToDateTime(row["start_date"]),
                EndDate = Convert.ToDateTime(row["end_date"]),
                Status = row["status"].ToString()!,
                Description = row["description"]?.ToString(),
                TotalEnrollments = row.Table.Columns.Contains("total_enrollments") && row["total_enrollments"] != DBNull.Value
                    ? Convert.ToInt32(row["total_enrollments"]) : null,
                TotalStudentsEnrolled = row.Table.Columns.Contains("total_students_enrolled") && row["total_students_enrolled"] != DBNull.Value
                    ? Convert.ToInt32(row["total_students_enrolled"]) : null,
                IsActive = Convert.ToBoolean(row["is_active"]),
                CreatedAt = Convert.ToDateTime(row["created_at"]),
                CreatedBy = row["created_by"]?.ToString()
            };
        }
    }
}

