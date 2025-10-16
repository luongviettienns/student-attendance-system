using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api/admin/lecturers")]
    public class LecturerController : ControllerBase
    {
        private readonly LecturerService _service;

        public LecturerController(LecturerService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _service.GetAllAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var lecturer = await _service.GetByIdAsync(id);
            if (lecturer == null) return NotFound();
            return Ok(lecturer);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Lecturer model)
        {
            try
            {
                await _service.AddAsync(model);
                return Ok(new { message = "✅ Thêm giảng viên thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Lecturer model)
        {
            if (id != model.LecturerId)
                return BadRequest(new { message = "ID không khớp!" });

            await _service.UpdateAsync(model);
            return Ok(new { message = "✅ Cập nhật giảng viên thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { message = "🗑 Xóa giảng viên thành công!" });
        }
    }
}
