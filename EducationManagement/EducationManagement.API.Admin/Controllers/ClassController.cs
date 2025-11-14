using EducationManagement.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using EducationManagement.Common.Helpers;
using System.Threading.Tasks;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/classes")]
    public class ClassController : ControllerBase
    {
        private readonly ClassService _classService;

        public ClassController(ClassService classService)
        {
            _classService = classService;
        }

        /// <summary>
        /// Lấy danh sách tất cả classes với pagination
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? subjectId = null,
            [FromQuery] string? lecturerId = null,
            [FromQuery] string? academicYearId = null)
        {
            try
            {
                var (items, totalCount) = await _classService.GetAllPagedAsync(
                    page, pageSize, search, subjectId, lecturerId, academicYearId);
                
                return Ok(new
                {
                    success = true,
                    data = items,
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy class theo ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var classItem = await _classService.GetClassByIdAsync(id);
                if (classItem == null)
                    return NotFound(new { message = "Không tìm thấy lớp học" });

                return Ok(new { data = classItem });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Tạo class mới
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateClassRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var classId = IdGenerator.Generate("class");
                var newId = await _classService.CreateClassAsync(
                    classId,
                    request.ClassCode,
                    request.ClassName,
                    request.SubjectId,
                    request.LecturerId,
                    request.Semester,
                    request.AcademicYearId,
                    request.MaxStudents,
                    request.CreatedBy ?? "system"
                );

                return Ok(new { message = "Tạo lớp học thành công", classId = newId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Cập nhật class
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateClassRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _classService.UpdateClassAsync(
                    id,
                    request.ClassCode,
                    request.ClassName,
                    request.SubjectId,
                    request.LecturerId,
                    request.Semester,
                    request.AcademicYearId,
                    request.MaxStudents,
                    request.UpdatedBy ?? "system"
                );

                return Ok(new { message = "Cập nhật lớp học thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Xóa class (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                await _classService.DeleteClassAsync(id, "system");
                return Ok(new { message = "Xóa lớp học thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy classes theo lecturer ID
        /// </summary>
        [HttpGet("lecturer/{lecturerId}")]
        public async Task<IActionResult> GetByLecturer(string lecturerId)
        {
            try
            {
                var classes = await _classService.GetClassesByLecturerAsync(lecturerId);
                return Ok(new { data = classes });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy classes theo student ID
        /// </summary>
        [HttpGet("student/{studentId}")]
        public async Task<IActionResult> GetByStudent(string studentId)
        {
            try
            {
                var classes = await _classService.GetClassesByStudentAsync(studentId);
                return Ok(new { data = classes });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }

    // DTOs for Class
    public class CreateClassRequest
    {
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string SubjectId { get; set; } = string.Empty;
        public string LecturerId { get; set; } = string.Empty;
        public string Semester { get; set; } = string.Empty;
        public string AcademicYearId { get; set; } = string.Empty;
        public int MaxStudents { get; set; } = 50;
        public string? CreatedBy { get; set; }
    }

    public class UpdateClassRequest
    {
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string SubjectId { get; set; } = string.Empty;
        public string LecturerId { get; set; } = string.Empty;
        public string Semester { get; set; } = string.Empty;
        public string AcademicYearId { get; set; } = string.Empty;
        public int MaxStudents { get; set; } = 50;
        public string? UpdatedBy { get; set; }
    }

    public class DeleteClassRequest
    {
        public string? DeletedBy { get; set; }
    }
}

