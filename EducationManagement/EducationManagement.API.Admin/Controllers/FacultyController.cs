using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api-edu/faculties")]
    public class FacultyController : ControllerBase
    {
        private readonly FacultyService _service;

        public FacultyController(FacultyService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string search = null)
        {
            try
            {
                var (items, totalCount) = await _service.GetAllPagedAsync(page, pageSize, search);
                
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
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null)
                return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Faculty f)
        {
            f.FacultyId = Guid.NewGuid().ToString();
            f.CreatedAt = DateTime.Now;
            await _service.AddAsync(f);
            return Ok(new { message = "✅ Tạo khoa thành công!" });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Faculty f)
        {
            if (id != f.FacultyId) return BadRequest();
            f.UpdatedAt = DateTime.Now;
            await _service.UpdateAsync(f);
            return Ok(new { message = "✅ Cập nhật khoa thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { message = "🗑 Xóa khoa thành công!" });
        }
    }
}
