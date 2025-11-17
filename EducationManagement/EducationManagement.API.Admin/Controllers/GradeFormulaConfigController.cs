using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.GradeFormula;
using EducationManagement.Common.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using EducationManagement.API.Admin.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/grade-formula-configs")]
    public class GradeFormulaConfigController : ControllerBase
    {
        private readonly GradeFormulaConfigService _formulaService;

        public GradeFormulaConfigController(GradeFormulaConfigService formulaService)
        {
            _formulaService = formulaService;
        }

        [HttpPost]
        [RequireAnyPermission("ADVISOR_GRADE_FORMULA", "ADMIN_GRADE_FORMULA")] // ✅ Permission từ database
        public async Task<IActionResult> Create([FromBody] GradeFormulaConfigCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var configId = await _formulaService.CreateConfigAsync(dto);
                return Ok(new { message = "Tạo cấu hình công thức thành công", configId });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet]
        // Cho phép tất cả user đã đăng nhập xem (Admin, Advisor, Lecturer) - [Authorize] đã có ở controller level
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string? subjectId = null,
            [FromQuery] string? classId = null,
            [FromQuery] string? schoolYearId = null,
            [FromQuery] bool? isDefault = null)
        {
            try
            {
                var (configs, totalCount) = await _formulaService.GetAllConfigsAsync(
                    page, pageSize, subjectId, classId, schoolYearId, isDefault);

                return Ok(new
                {
                    data = new
                    {
                        data = configs,
                        totalCount,
                        page,
                        pageSize
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        [RequireAnyPermission("ADVISOR_GRADE_FORMULA", "ADMIN_GRADE_FORMULA")] // ✅ Permission từ database
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var config = await _formulaService.GetConfigByIdAsync(id);
                if (config == null)
                    return NotFound(new { message = "Không tìm thấy cấu hình công thức" });

                return Ok(new { data = config });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("resolve")]
        [Authorize] // Cho phép tất cả user đã đăng nhập (Admin, Lecturer, Advisor) xem công thức điểm
        public async Task<IActionResult> GetByScope([FromQuery] GradeFormulaResolveRequestDto request)
        {
            try
            {
                var config = await _formulaService.GetConfigByScopeAsync(
                    request.ClassId, request.SubjectId, request.SchoolYearId);

                if (config == null)
                {
                    // Return default formula if not found
                    return Ok(new { 
                        data = new GradeFormulaConfigResponseDto
                        {
                            ConfigId = "DEFAULT",
                            MidtermWeight = 0.30m,
                            FinalWeight = 0.70m,
                            AssignmentWeight = 0.00m,
                            QuizWeight = 0.00m,
                            ProjectWeight = 0.00m,
                            RoundingMethod = "STANDARD",
                            DecimalPlaces = 2,
                            IsDefault = true
                        },
                        message = "Sử dụng công thức mặc định"
                    });
                }

                // Convert Model to DTO
                var dto = new GradeFormulaConfigResponseDto
                {
                    ConfigId = config.ConfigId,
                    SubjectId = config.SubjectId,
                    ClassId = config.ClassId,
                    SchoolYearId = config.SchoolYearId,
                    MidtermWeight = config.MidtermWeight,
                    FinalWeight = config.FinalWeight,
                    AssignmentWeight = config.AssignmentWeight,
                    QuizWeight = config.QuizWeight,
                    ProjectWeight = config.ProjectWeight,
                    CustomFormula = config.CustomFormula,
                    RoundingMethod = config.RoundingMethod,
                    DecimalPlaces = config.DecimalPlaces,
                    Description = config.Description,
                    IsDefault = config.IsDefault,
                    CreatedAt = config.CreatedAt,
                    CreatedBy = config.CreatedBy,
                    UpdatedAt = config.UpdatedAt,
                    UpdatedBy = config.UpdatedBy,
                    SubjectCode = config.SubjectCode,
                    SubjectName = config.SubjectName,
                    ClassCode = config.ClassCode,
                    ClassName = config.ClassName,
                    SchoolYearCode = config.SchoolYearCode,
                    SchoolYearName = config.SchoolYearName
                };

                return Ok(new { data = dto });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    message = "Lỗi hệ thống", 
                    error = ex.Message,
                    stackTrace = ex.StackTrace
                });
            }
        }

        [HttpPut("{id}")]
        [RequireAnyPermission("ADVISOR_GRADE_FORMULA", "ADMIN_GRADE_FORMULA")] // ✅ Permission từ database
        public async Task<IActionResult> Update(string id, [FromBody] GradeFormulaConfigUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _formulaService.UpdateConfigAsync(id, dto);
                return Ok(new { message = "Cập nhật cấu hình công thức thành công" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [RequireAnyPermission("ADVISOR_GRADE_FORMULA", "ADMIN_GRADE_FORMULA")] // ✅ Permission từ database
        public async Task<IActionResult> Delete(string id, [FromBody] DeleteConfigRequest request)
        {
            try
            {
                await _formulaService.DeleteConfigAsync(id, request.DeletedBy ?? "system");
                return Ok(new { message = "Xóa cấu hình công thức thành công" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }

    public class DeleteConfigRequest
    {
        public string? DeletedBy { get; set; }
    }
}

