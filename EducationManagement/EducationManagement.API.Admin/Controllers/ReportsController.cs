using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.Report;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/reports")]
    public class ReportsController : ControllerBase
    {
        private readonly ReportService _reportService;

        public ReportsController(ReportService reportService)
        {
            _reportService = reportService;
        }

        /// <summary>
        /// Get admin reports
        /// GET /api-edu/reports/admin
        /// </summary>
        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminReports(
            [FromQuery] string? schoolYearId = null,
            [FromQuery] int? semester = null,
            [FromQuery] string? facultyId = null,
            [FromQuery] string? majorId = null)
        {
            try
            {
                var report = await _reportService.GetAdminReportAsync(schoolYearId, semester, facultyId, majorId);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Get advisor reports
        /// GET /api-edu/reports/advisor
        /// </summary>
        [HttpGet("advisor")]
        [Authorize(Roles = "Admin,Advisor")]
        public async Task<IActionResult> GetAdvisorReports(
            [FromQuery] string? schoolYearId = null,
            [FromQuery] int? semester = null,
            [FromQuery] string? facultyId = null,
            [FromQuery] string? majorId = null,
            [FromQuery] string? classId = null,
            [FromQuery] int? cohortYear = null)
        {
            try
            {
                var report = await _reportService.GetAdvisorReportAsync(schoolYearId, semester, facultyId, majorId, classId, cohortYear);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Get lecturer reports
        /// GET /api-edu/reports/lecturer
        /// </summary>
        [HttpGet("lecturer")]
        [Authorize(Roles = "Admin,Lecturer")]
        public async Task<IActionResult> GetLecturerReports(
            [FromQuery] string? schoolYearId = null,
            [FromQuery] int? semester = null,
            [FromQuery] string? classId = null)
        {
            try
            {
                var report = await _reportService.GetLecturerReportAsync(schoolYearId, semester, classId);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Get student reports
        /// GET /api-edu/reports/student
        /// </summary>
        [HttpGet("student")]
        [Authorize(Roles = "Admin,Student")]
        public async Task<IActionResult> GetStudentReports(
            [FromQuery] string? schoolYearId = null,
            [FromQuery] int? semester = null)
        {
            try
            {
                // Get student ID from claims
                var studentId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(studentId))
                {
                    return Unauthorized(new { success = false, message = "Không tìm thấy thông tin sinh viên" });
                }

                var report = await _reportService.GetStudentReportAsync(studentId, schoolYearId, semester);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}
