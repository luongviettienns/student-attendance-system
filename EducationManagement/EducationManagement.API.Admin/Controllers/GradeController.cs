using EducationManagement.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using EducationManagement.Common.Helpers;
using System.Threading.Tasks;
using EducationManagement.API.Admin.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/grades")]
    public class GradeController : BaseController
    {
        private readonly GradeService _gradeService;

        public GradeController(GradeService gradeService, AuditLogService? auditLogService = null) 
            : base(auditLogService)
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
        [RequireAnyPermission("TCH_CLASSES", "ADMIN_STUDENTS")] // ✅ Permission từ database
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
                    request.GradedBy, request.CreatedBy ?? GetCurrentUserId() ?? "system"
                );

                // Audit log: CREATE GRADE
                await LogCreateAsync("Grade", newId, new
                {
                    studentId = request.StudentId,
                    classId = request.ClassId,
                    gradeType = request.GradeType,
                    score = request.Score,
                    maxScore = request.MaxScore,
                    weight = request.Weight
                });

                return Ok(new { message = "Tạo điểm thành công", gradeId = newId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [RequireAnyPermission("TCH_CLASSES", "ADMIN_STUDENTS")] // ✅ Permission từ database
        public async Task<IActionResult> Update(string id, [FromBody] UpdateGradeRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                // Get old grade values for audit log
                var oldGrade = await _gradeService.GetGradeByIdAsync(id);
                var oldValues = oldGrade != null ? new
                {
                    gradeType = oldGrade.MidtermScore.HasValue ? "Midterm" : oldGrade.FinalScore.HasValue ? "Final" : "Unknown",
                    score = oldGrade.MidtermScore ?? oldGrade.FinalScore ?? 0,
                    totalScore = oldGrade.TotalScore
                } : null;

                await _gradeService.UpdateGradeAsync(id, request.GradeType, request.Score,
                    request.MaxScore, request.Weight, request.Notes, request.UpdatedBy ?? GetCurrentUserId() ?? "system");

                // Get updated grade for audit log
                var newGrade = await _gradeService.GetGradeByIdAsync(id);
                var newValues = newGrade != null ? new
                {
                    gradeType = request.GradeType,
                    score = request.Score,
                    maxScore = request.MaxScore,
                    weight = request.Weight,
                    totalScore = newGrade.TotalScore
                } : null;

                // Audit log: UPDATE GRADE (BẮT BUỘC theo NFR)
                await LogUpdateAsync("Grade", id, oldValues, newValues);

                return Ok(new { message = "Cập nhật điểm thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [RequirePermission("ADMIN_STUDENTS")] // ✅ Permission từ database
        public async Task<IActionResult> Delete(string id, [FromBody] DeleteGradeRequest request)
        {
            try
            {
                // Get grade before deletion for audit log
                var grade = await _gradeService.GetGradeByIdAsync(id);
                var gradeData = grade != null ? new
                {
                    studentId = grade.StudentId,
                    classId = grade.ClassId,
                    midtermScore = grade.MidtermScore,
                    finalScore = grade.FinalScore,
                    totalScore = grade.TotalScore
                } : null;

                await _gradeService.DeleteGradeAsync(id, request.DeletedBy ?? GetCurrentUserId() ?? "system");

                // Audit log: DELETE GRADE
                await LogDeleteAsync("Grade", id, gradeData);

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

        [HttpGet("student/{studentId}/school-year/{schoolYearId}")]
        public async Task<IActionResult> GetByStudentSchoolYear(string studentId, string schoolYearId, [FromQuery] string? semester = null)
        {
            try
            {
                var grades = await _gradeService.GetGradesByStudentSchoolYearAsync(studentId, schoolYearId, semester);
                return Ok(new { data = grades });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("student/{studentId}/summary")]
        public async Task<IActionResult> GetGradeSummary(string studentId, [FromQuery] string? schoolYearId = null, [FromQuery] string? semester = null)
        {
            try
            {
                var summary = await _gradeService.GetGradeSummaryAsync(studentId, schoolYearId, semester);
                return Ok(new { data = summary });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("student/{studentId}/cumulative")]
        public async Task<IActionResult> GetCumulativeGPA(string studentId)
        {
            try
            {
                var cumulativeGPA = await _gradeService.GetCumulativeGPAAsync(studentId);
                if (cumulativeGPA == null)
                    return NotFound(new { message = "Không tìm thấy dữ liệu GPA tích lũy" });

                return Ok(new { data = cumulativeGPA });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("student/{studentId}/transcript")]
        public async Task<IActionResult> GetStudentTranscript(string studentId)
        {
            try
            {
                var transcript = await _gradeService.GetStudentTranscriptAsync(studentId);
                return Ok(new { data = transcript });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpPost("calculate/student/{studentId}/school-year/{schoolYearId}")]
        public async Task<IActionResult> CalculateGPA(string studentId, string schoolYearId, [FromQuery] string? semester = null)
        {
            try
            {
                await _gradeService.CalculateGPABySchoolYearAsync(studentId, schoolYearId, semester);
                return Ok(new { message = "Tính GPA thành công" });
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

