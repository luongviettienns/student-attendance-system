using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.Enrollment;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/enrollments")]
    public class EnrollmentController : ControllerBase
    {
        private readonly EnrollmentService _service;

        public EnrollmentController(EnrollmentService service)
        {
            _service = service;
        }

        // ============================================================
        // 1️⃣ GET ALL
        // ============================================================
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var enrollments = await _service.GetAllEnrollmentsAsync();
                return Ok(new
                {
                    success = true,
                    data = enrollments,
                    totalCount = enrollments.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 2️⃣ GET BY ID
        // ============================================================
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var enrollment = await _service.GetEnrollmentByIdAsync(id);
                if (enrollment == null)
                    return NotFound(new { success = false, message = "Không tìm thấy đăng ký học phần" });

                return Ok(new { success = true, data = enrollment });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 3️⃣ GET BY STUDENT
        // ============================================================
        [HttpGet("student/{studentId}")]
        public async Task<IActionResult> GetByStudent(string studentId)
        {
            try
            {
                var enrollments = await _service.GetEnrollmentsByStudentAsync(studentId);
                return Ok(new
                {
                    success = true,
                    data = enrollments,
                    totalCount = enrollments.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 4️⃣ GET BY CLASS
        // ============================================================
        [HttpGet("class/{classId}")]
        public async Task<IActionResult> GetByClass(string classId)
        {
            try
            {
                var enrollments = await _service.GetEnrollmentsByClassAsync(classId);
                return Ok(new
                {
                    success = true,
                    data = enrollments,
                    totalCount = enrollments.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 5️⃣ REGISTER (Student)
        // ============================================================
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterEnrollmentDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                var enrollmentId = await _service.RegisterAsync(dto.StudentId, dto.ClassId, userId);

                return Ok(new
                {
                    success = true,
                    message = "Đăng ký học phần thành công",
                    enrollmentId
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 6️⃣ APPROVE (Admin Only)
        // ============================================================
        [HttpPost("{id}/approve")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Approve(string id)
        {
            try
            {
                var approvedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.ApproveAsync(id, approvedBy);

                return Ok(new { success = true, message = "Đã phê duyệt đăng ký thành công" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 7️⃣ DROP ENROLLMENT (Student)
        // ============================================================
        [HttpPost("{id}/drop")]
        public async Task<IActionResult> Drop(string id, [FromBody] DropEnrollmentDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.DropAsync(id, dto.Reason, userId);

                return Ok(new { success = true, message = "Đã hủy đăng ký học phần thành công" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 8️⃣ WITHDRAW (Admin Only)
        // ============================================================
        [HttpPost("{id}/withdraw")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Withdraw(string id, [FromBody] WithdrawEnrollmentDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var withdrawnBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.WithdrawAsync(id, dto.Reason, withdrawnBy);

                return Ok(new { success = true, message = "Đã rút học phần thành công" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 9️⃣ GET ENROLLMENT SUMMARY (Student)
        // ============================================================
        [HttpGet("student/{studentId}/summary")]
        public async Task<IActionResult> GetSummary(
            string studentId,
            [FromQuery] int? semester = null,
            [FromQuery] string? academicYearId = null)
        {
            try
            {
                var summary = await _service.GetSummaryAsync(studentId, semester, academicYearId);
                return Ok(new { success = true, data = summary });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔟 GET AVAILABLE CLASSES (Student)
        // ============================================================
        [HttpGet("student/{studentId}/available-classes")]
        public async Task<IActionResult> GetAvailableClasses(
            string studentId,
            [FromQuery] int? semester = null,
            [FromQuery] string? academicYearId = null)
        {
            try
            {
                var classes = await _service.GetAvailableClassesAsync(studentId, semester, academicYearId);
                return Ok(new
                {
                    success = true,
                    data = classes,
                    totalCount = classes.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}
