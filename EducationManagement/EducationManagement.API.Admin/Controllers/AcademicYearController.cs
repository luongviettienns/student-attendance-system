using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api-edu/academic-years")]
    public class AcademicYearController : ControllerBase
    {
        private readonly AcademicYearService _service;

        public AcademicYearController(AcademicYearService service)
        {
            _service = service;
        }

        // ============================================================
        // 🔹 BASIC CRUD
        // ============================================================

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _service.GetAllAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null) return NotFound(new { message = "❌ Không tìm thấy niên khóa!" });
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] AcademicYear model)
        {
            try
            {
                var userName = User.Identity?.Name ?? "admin";
                await _service.AddAsync(model, userName);
                return Ok(new { message = "✅ Thêm niên khóa thành công!", data = model });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] AcademicYear model)
        {
            try
            {
                if (id != model.AcademicYearId)
                    return BadRequest(new { message = "❌ ID không khớp!" });

                var userName = User.Identity?.Name ?? "admin";
                await _service.UpdateAsync(model, userName);
                return Ok(new { message = "✅ Cập nhật niên khóa thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new { message = "🗑 Xóa niên khóa thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ============================================================
        // 🔹 AUTO-CREATION ENDPOINTS
        // ============================================================

        /// <summary>
        /// TỰ ĐỘNG tạo niên khóa (cohort) theo chuẩn VN (4 năm)
        /// </summary>
        /// <param name="startYear">Năm bắt đầu (VD: 2025 → K25)</param>
        /// <param name="durationYears">Số năm (mặc định 4)</param>
        [HttpPost("auto-create-cohort")]
        public async Task<IActionResult> AutoCreateCohort([FromQuery] int startYear, [FromQuery] int durationYears = 4)
        {
            try
            {
                var userName = User.Identity?.Name ?? "system";
                var cohort = await _service.AutoCreateCohortAsync(startYear, durationYears, userName);
                
                return Ok(new 
                { 
                    message = $"✅ Đã tự động tạo niên khóa {cohort.CohortCode}",
                    data = cohort
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// TỰ ĐỘNG tạo nhiều niên khóa cùng lúc
        /// </summary>
        /// <param name="startYears">Danh sách năm bắt đầu (VD: [2021,2022,2023,2024,2025])</param>
        /// <param name="durationYears">Số năm (mặc định 4)</param>
        [HttpPost("auto-create-multiple-cohorts")]
        public async Task<IActionResult> AutoCreateMultipleCohorts([FromBody] int[] startYears, [FromQuery] int durationYears = 4)
        {
            try
            {
                var userName = User.Identity?.Name ?? "system";
                var cohorts = await _service.AutoCreateMultipleCohortsAsync(startYears, durationYears, userName);
                
                return Ok(new 
                { 
                    message = $"✅ Đã tạo {cohorts.Count} niên khóa",
                    data = cohorts
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ============================================================
        // 🔹 QUERY ENDPOINTS
        // ============================================================

        /// <summary>
        /// Lấy các niên khóa đang hoạt động (còn trong thời gian đào tạo)
        /// </summary>
        [HttpGet("active-cohorts")]
        [AllowAnonymous]
        public async Task<IActionResult> GetActiveCohorts()
        {
            var cohorts = await _service.GetActiveCohortsAsync();
            return Ok(cohorts);
        }

        /// <summary>
        /// Lấy các niên khóa cho năm hiện tại
        /// </summary>
        [HttpGet("current-cohorts")]
        [AllowAnonymous]
        public async Task<IActionResult> GetCurrentCohorts()
        {
            var cohorts = await _service.GetCohortsForCurrentYearAsync();
            return Ok(cohorts);
        }
    }
}
