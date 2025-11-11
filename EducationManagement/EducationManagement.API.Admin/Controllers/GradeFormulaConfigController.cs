using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.GradeFormula;
using EducationManagement.Common.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

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
        [Authorize(Roles = "Advisor,Admin")]
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
        [Authorize(Roles = "Advisor,Admin")]
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
        [Authorize(Roles = "Advisor,Admin")]
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
        [Authorize(Roles = "Advisor,Admin,Lecturer")]
        public async Task<IActionResult> GetByScope([FromQuery] GradeFormulaResolveRequestDto request)
        {
            try
            {
                var config = await _formulaService.GetConfigByScopeAsync(
                    request.ClassId, request.SubjectId, request.SchoolYearId);

                if (config == null)
                    return NotFound(new { message = "Không tìm thấy cấu hình công thức cho scope này" });

                return Ok(new { data = config });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Advisor,Admin")]
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
        [Authorize(Roles = "Advisor,Admin")]
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

