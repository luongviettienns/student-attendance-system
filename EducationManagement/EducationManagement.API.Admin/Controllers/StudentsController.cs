using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.Student;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/students")]
    public class StudentsController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly StudentService _studentService;

        public StudentsController(StudentService studentService, IWebHostEnvironment env)
        {
            _studentService = studentService;
            _env = env;
        }

        // ============================================================
        // 🔹 1️⃣ THÊM SINH VIÊN
        // ============================================================
        [HttpPost("addstudent")]
        public async Task<IActionResult> AddStudent([FromBody] StudentCreateDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _studentService.AddStudentAsync(model);
                return Ok(new { success = true, message = "Thêm sinh viên thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        // ============================================================
        // 🔹 2️⃣ CẬP NHẬT SINH VIÊN
        // ============================================================
        [HttpPut("update")]
        public async Task<IActionResult> UpdateStudentFull([FromBody] UpdateStudentFullDto request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _studentService.UpdateStudentAsync(request);
                return Ok(new { message = "Cập nhật sinh viên (sp_UpdateStudentFull) thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 3️⃣ XOÁ SINH VIÊN (SOFT DELETE)
        // ============================================================
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteStudentFull([FromBody] DeleteStudentFullDto dto)
        {
            try
            {
                await _studentService.DeleteStudentAsync(dto.StudentId, dto.DeletedBy);
                return Ok(new { message = "Xóa sinh viên (sp_DeleteStudentFull) thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 4️⃣ LẤY DANH SÁCH SINH VIÊN (PHÂN TRANG + LỌC)
        // ============================================================
        [HttpGet]
        public async Task<IActionResult> GetAllStudents(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? facultyId = null,
            [FromQuery] string? majorId = null,
            [FromQuery] string? academicYearId = null)
        {
            try
            {
                var (students, totalCount) = await _studentService.GetAllStudentsAsync(
                    page, pageSize, search, facultyId, majorId, academicYearId);

                return Ok(new
                {
                    data = students,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 5️⃣ LẤY SINH VIÊN THEO ID
        // ============================================================
        [HttpGet("{id}")]
        public async Task<IActionResult> GetStudentById(string id)
        {
            try
            {
                var student = await _studentService.GetStudentByIdAsync(id);
                if (student == null)
                    return NotFound(new { message = "Không tìm thấy sinh viên" });

                return Ok(new { data = student });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}
