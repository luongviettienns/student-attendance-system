using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api-edu/lecturers")]
    public class LecturerController : BaseController
    {
        private readonly LecturerService _service;

        public LecturerController(LecturerService service, AuditLogService auditLogService) : base(auditLogService)
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

                // ✅ Audit Log: Create Lecturer
                await LogCreateAsync("Lecturer", model.LecturerId, new {
                    user_id = model.UserId,
                    full_name = model.FullName,
                    department_id = model.DepartmentId,
                    academic_title = model.AcademicTitle
                });

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

            var oldLecturer = await _service.GetByIdAsync(id);
            await _service.UpdateAsync(model);

            // ✅ Audit Log: Update Lecturer
            if (oldLecturer != null)
            {
                await LogUpdateAsync("Lecturer", model.LecturerId,
                    new { full_name = oldLecturer.FullName, department_id = oldLecturer.DepartmentId },
                    new { full_name = model.FullName, department_id = model.DepartmentId });
            }

            return Ok(new { message = "✅ Cập nhật giảng viên thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var lecturer = await _service.GetByIdAsync(id);
            await _service.DeleteAsync(id);

            // ✅ Audit Log: Delete Lecturer
            if (lecturer != null)
            {
                await LogDeleteAsync("Lecturer", id, new {
                    full_name = lecturer.FullName,
                    user_id = lecturer.UserId,
                    department_id = lecturer.DepartmentId
                });
            }

            return Ok(new { message = "🗑 Xóa giảng viên thành công!" });
        }
    }
}
