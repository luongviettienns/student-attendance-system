using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api/admin/faculties")]
    public class FacultyController : ControllerBase
    {
        private readonly FacultyService _service;

        public FacultyController(FacultyService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
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
