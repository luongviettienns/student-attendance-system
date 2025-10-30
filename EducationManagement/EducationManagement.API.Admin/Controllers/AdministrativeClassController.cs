using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.AdministrativeClass;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/admin-classes")]
    public class AdministrativeClassController : ControllerBase
    {
        private readonly AdministrativeClassService _service;

        public AdministrativeClassController(AdministrativeClassService service)
        {
            _service = service;
        }

        // ============================================================
        // 1️⃣ GET ALL with Pagination & Filters
        // ============================================================
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? majorId = null,
            [FromQuery] int? cohortYear = null,
            [FromQuery] string? advisorId = null)
        {
            try
            {
                var (data, totalCount) = await _service.GetAllAsync(
                    page, pageSize, search, majorId, cohortYear, advisorId);

                return Ok(new
                {
                    success = true,
                    data,
                    totalCount,
                    page,
                    pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
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
                var result = await _service.GetByIdAsync(id);
                if (result == null)
                    return NotFound(new { success = false, message = "Không tìm thấy lớp hành chính" });

                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 3️⃣ GET STUDENTS BY CLASS
        // ============================================================
        [HttpGet("{id}/students")]
        public async Task<IActionResult> GetStudents(string id)
        {
            try
            {
                var students = await _service.GetStudentsAsync(id);
                return Ok(new { success = true, data = students, totalCount = students.Count });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 4️⃣ GET CLASS REPORT
        // ============================================================
        [HttpGet("{id}/report")]
        public async Task<IActionResult> GetReport(
            string id,
            [FromQuery] int? semester = null,
            [FromQuery] string? academicYearId = null)
        {
            try
            {
                var report = await _service.GetReportAsync(id, semester, academicYearId);
                if (report == null)
                    return NotFound(new { success = false, message = "Không tìm thấy báo cáo" });

                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 5️⃣ CREATE (Admin Only)
        // ============================================================
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Create([FromBody] CreateAdminClassDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var createdBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                var classId = await _service.CreateAsync(dto, createdBy);

                return Ok(new
                {
                    success = true,
                    message = "Tạo lớp hành chính thành công",
                    classId
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
        // 6️⃣ UPDATE (Admin Only)
        // ============================================================
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateAdminClassDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var updatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.UpdateAsync(id, dto, updatedBy);

                return Ok(new { success = true, message = "Cập nhật lớp hành chính thành công" });
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
        // 7️⃣ DELETE (Admin Only)
        // ============================================================
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var deletedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.DeleteAsync(id, deletedBy);

                return Ok(new { success = true, message = "Xóa lớp hành chính thành công" });
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
        // 8️⃣ ASSIGN STUDENTS (Admin Only)
        // ============================================================
        [HttpPost("{id}/assign-students")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AssignStudents(string id, [FromBody] AssignStudentsDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var assignedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.AssignStudentsAsync(id, dto.StudentIds, assignedBy);

                return Ok(new
                {
                    success = true,
                    message = $"Đã phân {dto.StudentIds.Count} sinh viên vào lớp thành công"
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
        // 9️⃣ REMOVE STUDENT (Admin Only)
        // ============================================================
        [HttpDelete("{classId}/students/{studentId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RemoveStudent(string classId, string studentId)
        {
            try
            {
                var removedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.RemoveStudentAsync(studentId, removedBy);

                return Ok(new { success = true, message = "Đã xóa sinh viên khỏi lớp thành công" });
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
    }
}

