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
            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] AcademicYear model)
        {
            try
            {
                await _service.AddAsync(model);
                return Ok(new { message = "✅ Thêm niên khóa thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] AcademicYear model)
        {
            if (id != model.AcademicYearId)
                return BadRequest(new { message = "ID không khớp!" });

            await _service.UpdateAsync(model);
            return Ok(new { message = "✅ Cập nhật niên khóa thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { message = "🗑 Xóa niên khóa thành công!" });
        }
    }
}
