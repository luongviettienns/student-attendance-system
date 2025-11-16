using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.Retake;
using EducationManagement.Common.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using EducationManagement.API.Admin.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    /// <summary>
    /// Controller for Retake Records Management
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("api-edu/retakes")]
    public class RetakeController : ControllerBase
    {
        private readonly RetakeService _retakeService;

        public RetakeController(RetakeService retakeService)
        {
            _retakeService = retakeService;
        }

        /// <summary>
        /// Create retake record manually
        /// </summary>
        [HttpPost]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS")] // ✅ Permission từ database
        public async Task<IActionResult> Create([FromBody] RetakeRecordCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var retakeId = await _retakeService.CreateRetakeRecordAsync(dto);
                return Ok(new { message = "Tạo bản ghi học lại thành công", retakeId });
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

        /// <summary>
        /// Get retake record by ID
        /// </summary>
        [HttpGet("{id}")]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS", "STUDENT_SECTION_STUDY")] // ✅ Permission từ database
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var retake = await _retakeService.GetRetakeRecordByIdAsync(id);
                if (retake == null)
                    return NotFound(new { message = "Không tìm thấy bản ghi học lại" });

                return Ok(new { data = retake });
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

        /// <summary>
        /// Get retake records by student ID
        /// </summary>
        [HttpGet("student/{studentId}")]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS", "STUDENT_SECTION_STUDY")] // ✅ Permission từ database
        public async Task<IActionResult> GetByStudent(
            string studentId,
            [FromQuery] string? status = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                // Students can only see their own retakes
                var currentUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                var isStudent = User.IsInRole("Student");
                
                if (isStudent && currentUserId != studentId)
                {
                    return Forbid("Bạn chỉ có thể xem bản ghi học lại của chính mình");
                }

                var (records, totalCount) = await _retakeService.GetRetakeRecordsByStudentAsync(
                    studentId, status, page, pageSize);

                return Ok(new
                {
                    data = records,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                    }
                });
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

        /// <summary>
        /// Get retake records by class ID
        /// </summary>
        [HttpGet("class/{classId}")]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS", "TCH_CLASSES")] // ✅ Permission từ database
        public async Task<IActionResult> GetByClass(
            string classId,
            [FromQuery] string? status = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                var (records, totalCount) = await _retakeService.GetRetakeRecordsByClassAsync(
                    classId, status, page, pageSize);

                return Ok(new
                {
                    data = records,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                    }
                });
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

        /// <summary>
        /// Update retake status (approve/reject)
        /// </summary>
        [HttpPut("{id}/status")]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS")] // ✅ Permission từ database
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] RetakeRecordUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var updatedBy = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? "system";
                dto.UpdatedBy = updatedBy;

                await _retakeService.UpdateRetakeStatusAsync(id, dto);
                return Ok(new { message = "Cập nhật trạng thái học lại thành công" });
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

        /// <summary>
        /// Get all retake records (for admin/advisor)
        /// </summary>
        [HttpGet]
        [RequireAnyPermission("ADVISOR_STUDENTS", "ADMIN_STUDENTS")] // ✅ Permission từ database
        public async Task<IActionResult> GetAll(
            [FromQuery] string? studentId = null,
            [FromQuery] string? classId = null,
            [FromQuery] string? status = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            try
            {
                // If studentId provided, get by student
                if (!string.IsNullOrWhiteSpace(studentId))
                {
                    var (records, totalCount) = await _retakeService.GetRetakeRecordsByStudentAsync(
                        studentId, status, page, pageSize);

                    return Ok(new
                    {
                        data = records,
                        pagination = new
                        {
                            page,
                            pageSize,
                            totalCount,
                            totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                        }
                    });
                }

                // If classId provided, get by class
                if (!string.IsNullOrWhiteSpace(classId))
                {
                    var (records, totalCount) = await _retakeService.GetRetakeRecordsByClassAsync(
                        classId, status, page, pageSize);

                    return Ok(new
                    {
                        data = records,
                        pagination = new
                        {
                            page,
                            pageSize,
                            totalCount,
                            totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                        }
                    });
                }

                // If no filter, return bad request
                return BadRequest(new { message = "Phải cung cấp studentId hoặc classId" });
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

