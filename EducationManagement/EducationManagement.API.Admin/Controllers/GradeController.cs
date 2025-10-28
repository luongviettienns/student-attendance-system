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
    [Route("api-edu/grades")]
    public class GradeController : ControllerBase
    {
        private readonly GradeService _gradeService;

        public GradeController(GradeService gradeService)
        {
            _gradeService = gradeService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var grades = await _gradeService.GetAllGradesAsync();
                return Ok(new { data = grades });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var grade = await _gradeService.GetGradeByIdAsync(id);
                if (grade == null)
                    return NotFound(new { message = "Không tìm thấy điểm" });

                return Ok(new { data = grade });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateGradeRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var gradeId = IdGenerator.Generate("grade");
                var newId = await _gradeService.CreateGradeAsync(
                    gradeId, request.StudentId, request.ClassId, request.GradeType,
                    request.Score, request.MaxScore, request.Weight, request.Notes,
                    request.GradedBy, request.CreatedBy ?? "system"
                );

                return Ok(new { message = "Tạo điểm thành công", gradeId = newId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateGradeRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _gradeService.UpdateGradeAsync(id, request.GradeType, request.Score,
                    request.MaxScore, request.Weight, request.Notes, request.UpdatedBy ?? "system");

                return Ok(new { message = "Cập nhật điểm thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id, [FromBody] DeleteGradeRequest request)
        {
            try
            {
                await _gradeService.DeleteGradeAsync(id, request.DeletedBy ?? "system");
                return Ok(new { message = "Xóa điểm thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("student/{studentId}")]
        public async Task<IActionResult> GetByStudent(string studentId)
        {
            try
            {
                var grades = await _gradeService.GetGradesByStudentAsync(studentId);
                return Ok(new { data = grades });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("class/{classId}")]
        public async Task<IActionResult> GetByClass(string classId)
        {
            try
            {
                var grades = await _gradeService.GetGradesByClassAsync(classId);
                return Ok(new { data = grades });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }

    public class CreateGradeRequest
    {
        public string StudentId { get; set; } = string.Empty;
        public string ClassId { get; set; } = string.Empty;
        public string GradeType { get; set; } = string.Empty; // Quiz, Midterm, Final, etc.
        public decimal Score { get; set; }
        public decimal MaxScore { get; set; } = 10.0m;
        public decimal Weight { get; set; } = 1.0m;
        public string? Notes { get; set; }
        public string? GradedBy { get; set; }
        public string? CreatedBy { get; set; }
    }

    public class UpdateGradeRequest
    {
        public string GradeType { get; set; } = string.Empty;
        public decimal Score { get; set; }
        public decimal MaxScore { get; set; } = 10.0m;
        public decimal Weight { get; set; } = 1.0m;
        public string? Notes { get; set; }
        public string? UpdatedBy { get; set; }
    }

    public class DeleteGradeRequest
    {
        public string? DeletedBy { get; set; }
    }
}

