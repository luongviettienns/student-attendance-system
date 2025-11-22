using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs.RegistrationPeriod;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EducationManagement.API.Admin.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/registration-periods")]
    public class RegistrationPeriodController : ControllerBase
    {
        private readonly RegistrationPeriodService _service;

        public RegistrationPeriodController(RegistrationPeriodService service)
        {
            _service = service;
        }

        // ============================================================
        // 1️⃣ GET ALL
        // ============================================================
        [HttpGet]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetAll([FromQuery] string? periodType = null)
        {
            try
            {
                var periods = await _service.GetAllAsync(periodType);
                return Ok(new
                {
                    success = true,
                    data = periods,
                    totalCount = periods.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 1️⃣.1 GET RETAKE PERIODS
        // ============================================================
        [HttpGet("retake")]
        [RequirePermission("VIEW_RETAKE_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetRetakePeriods()
        {
            try
            {
                var periods = await _service.GetRetakePeriodsAsync();
                return Ok(new
                {
                    success = true,
                    data = periods,
                    totalCount = periods.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 2️⃣ GET ACTIVE PERIOD (Admin/Advisor)
        // ============================================================
        [HttpGet("active")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetActive()
        {
            try
            {
                var activePeriod = await _service.GetActiveAsync();
                // Trả về 200 để FE không báo 404 khi không có đợt mở
                if (activePeriod == null)
                    return Ok(new { success = false, message = "Không có đợt đăng ký nào đang mở", data = (object?)null });

                return Ok(new { success = true, data = activePeriod });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 2️⃣.1 GET ACTIVE PERIOD FOR STUDENT (Student)
        // ============================================================
        [HttpGet("active/student")]
        [RequireAnyPermission("STUDENT_ENROLLMENT", "VIEW_RETAKE_PERIODS")] // ✅ Cho phép student xem đợt đăng ký đang mở
        public async Task<IActionResult> GetActiveForStudent()
        {
            try
            {
                var activePeriod = await _service.GetActiveAsync();
                // Trả về 200 để FE không báo 404 khi không có đợt mở
                if (activePeriod == null)
                    return Ok(new { success = false, message = "Không có đợt đăng ký nào đang mở", data = (object?)null });

                return Ok(new { success = true, data = activePeriod });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 3️⃣ GET BY ID
        // ============================================================
        [HttpGet("{id}")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var period = await _service.GetByIdAsync(id);
                if (period == null)
                    return NotFound(new { success = false, message = "Không tìm thấy đợt đăng ký" });

                return Ok(new { success = true, data = period });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 4️⃣ CREATE (Admin Only)
        // ============================================================
        [HttpPost]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> Create([FromBody] CreatePeriodDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var createdBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                var periodId = await _service.CreateAsync(dto, createdBy);

                return Ok(new
                {
                    success = true,
                    message = "Tạo đợt đăng ký thành công",
                    periodId
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
        // 5️⃣ UPDATE (Admin Only)
        // ============================================================
        [HttpPut("{id}")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> Update(string id, [FromBody] UpdatePeriodDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var updatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.UpdateAsync(id, dto, updatedBy);

                return Ok(new { success = true, message = "Cập nhật đợt đăng ký thành công" });
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
        // 6️⃣ DELETE (Admin Only)
        // ============================================================
        [HttpDelete("{id}")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var deletedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.DeleteAsync(id, deletedBy);

                return Ok(new { success = true, message = "Xóa đợt đăng ký thành công" });
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
        // 7️⃣ OPEN PERIOD (Admin Only)
        // ============================================================
        [HttpPost("{id}/open")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> Open(string id)
        {
            try
            {
                var openedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.OpenPeriodAsync(id, openedBy);

                return Ok(new
                {
                    success = true,
                    message = "Đã mở đợt đăng ký thành công. Các đợt khác đã tự động đóng."
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
        // 8️⃣ CLOSE PERIOD (Admin Only)
        // ============================================================
        [HttpPost("{id}/close")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> Close(string id)
        {
            try
            {
                var closedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.ClosePeriodAsync(id, closedBy);

                return Ok(new { success = true, message = "Đã đóng đợt đăng ký thành công" });
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
        // 9️⃣ PERIOD CLASSES MANAGEMENT
        // ============================================================
        [HttpGet("{id}/classes")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetClassesByPeriod(string id)
        {
            try
            {
                var data = await _service.GetClassesByPeriodAsync(id);
                return Ok(new { success = true, data });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("{id}/available-classes")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> GetAvailableClassesForPeriod(string id)
        {
            try
            {
                var data = await _service.GetAvailableClassesForPeriodAsync(id);
                return Ok(new { success = true, data });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("{id}/classes")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> AddClassToPeriod(string id, [FromBody] AddClassToPeriodInput input)
        {
            try
            {
                var createdBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.AddClassToPeriodAsync(id, input.ClassId, createdBy);
                return Ok(new { success = true, message = "Thêm lớp vào đợt đăng ký thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("classes/{periodClassId}")]
        [RequirePermission("ADMIN_REGISTRATION_PERIODS")] // ✅ Permission từ database
        public async Task<IActionResult> RemoveClassFromPeriod(string periodClassId)
        {
            try
            {
                var updatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system";
                await _service.RemoveClassFromPeriodAsync(periodClassId, updatedBy);
                return Ok(new { success = true, message = "Xóa lớp khỏi đợt đăng ký thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }

    public class AddClassToPeriodInput
    {
        public string ClassId { get; set; } = string.Empty;
    }
}

