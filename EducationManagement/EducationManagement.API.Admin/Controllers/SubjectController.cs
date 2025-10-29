using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api-edu/subjects")]
    public class SubjectController : ControllerBase
    {
        private readonly SubjectService _service;

        public SubjectController(SubjectService service)
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
            var subject = await _service.GetByIdAsync(id);
            if (subject == null) return NotFound();
            return Ok(subject);
        }

        [HttpGet("by-department/{depId}")]
        public async Task<IActionResult> GetByDepartment(string depId)
        {
            var list = await _service.GetByDepartmentAsync(depId);
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Subject model)
        {
            try
            {
                await _service.AddAsync(model);
                return Ok(new { message = "Thêm môn học thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Subject model)
        {
            if (id != model.SubjectId)
                return BadRequest(new { message = "ID không khớp!" });

            await _service.UpdateAsync(model);
            return Ok(new { message = "Cập nhật môn học thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            await _service.DeleteAsync(id);
            return Ok(new { message = "Xóa môn học thành công!" });
        }
    }
}
