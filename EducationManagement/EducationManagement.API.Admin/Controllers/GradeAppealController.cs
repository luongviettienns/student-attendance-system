using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.GradeAppeal;
using EducationManagement.Common.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/grade-appeals")]
    public class GradeAppealController : ControllerBase
    {
        private readonly GradeAppealService _appealService;

        public GradeAppealController(GradeAppealService appealService)
        {
            _appealService = appealService;
        }

        [HttpPost]
        [Authorize(Roles = "Student,Admin")]
        public async Task<IActionResult> Create([FromBody] GradeAppealCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var appealId = await _appealService.CreateAppealAsync(dto);
                return Ok(new { message = "Tạo yêu cầu phúc khảo thành công", appealId });
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
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            [FromQuery] string? status = null,
            [FromQuery] string? studentId = null,
            [FromQuery] string? lecturerId = null,
            [FromQuery] string? advisorId = null,
            [FromQuery] string? classId = null,
            [FromQuery] string? priority = null)
        {
            try
            {
                var (appeals, totalCount) = await _appealService.GetAllAppealsAsync(
                    page, pageSize, status, studentId, lecturerId, advisorId, classId, priority);

                return Ok(new
                {
                    data = appeals,
                    totalCount,
                    page,
                    pageSize
                });
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
                var appeal = await _appealService.GetAppealByIdAsync(id);
                if (appeal == null)
                    return NotFound(new { message = "Không tìm thấy yêu cầu phúc khảo" });

                return Ok(new { data = appeal });
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

        [HttpPut("{id}/lecturer-response")]
        [Authorize(Roles = "Lecturer,Admin")]
        public async Task<IActionResult> UpdateLecturerResponse(string id, [FromBody] GradeAppealLecturerResponseDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _appealService.UpdateLecturerResponseAsync(id, dto);
                return Ok(new { message = "Cập nhật phản hồi giảng viên thành công" });
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

        [HttpPut("{id}/advisor-decision")]
        [Authorize(Roles = "Advisor,Admin")]
        public async Task<IActionResult> UpdateAdvisorDecision(string id, [FromBody] GradeAppealAdvisorDecisionDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _appealService.UpdateAdvisorDecisionAsync(id, dto);
                return Ok(new { message = "Cập nhật quyết định cố vấn thành công" });
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

        [HttpPut("{id}/cancel")]
        [Authorize(Roles = "Student,Admin")]
        public async Task<IActionResult> Cancel(string id, [FromBody] GradeAppealCancelDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _appealService.CancelAppealAsync(id, dto.CancelledBy);
                return Ok(new { message = "Hủy yêu cầu phúc khảo thành công" });
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
}

