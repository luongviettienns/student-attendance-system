using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api/admin/majors")]
    public class MajorController : ControllerBase
    {
        private readonly MajorService _service;

        public MajorController(MajorService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var data = await _service.GetAllAsync();
            return Ok(data);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var major = await _service.GetByIdAsync(id);
            if (major == null) return NotFound();
            return Ok(major);
        }

        [HttpGet("by-faculty/{facultyId}")]
        public async Task<IActionResult> GetByFaculty(string facultyId)
        {
            var list = await _service.GetByFacultyAsync(facultyId);
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Major model)
        {
            try
            {
                await _service.AddAsync(model);
                return Ok(new { message = "✅ Thêm ngành học thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Major model)
        {
            if (id != model.MajorId)
                return BadRequest(new { message = "ID không khớp!" });

            await _service.UpdateAsync(model);
            return Ok(new { message = "✅ Cập nhật ngành học thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { message = "🗑 Xóa ngành học thành công!" });
        }
    }
}
