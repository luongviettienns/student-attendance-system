using Microsoft.AspNetCore.Mvc;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize] // ✅ Yêu cầu authentication, nhưng không giới hạn role
    [Route("api-edu/majors")]
    public class MajorController : BaseController
    {
        private readonly MajorService _service;

        public MajorController(MajorService service, AuditLogService auditLogService) : base(auditLogService)
        {
            _service = service;
        }

        [HttpGet]
        [Authorize(Roles = "Admin,Student,Lecturer,Advisor")] // ✅ Cho phép tất cả roles đã authenticated (bao gồm Advisor)
        public async Task<IActionResult> GetAll()
        {
            var data = await _service.GetAllAsync();
            return Ok(new { data = data });
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,Student,Lecturer,Advisor")] // ✅ Cho phép tất cả roles đã authenticated (bao gồm Advisor)
        public async Task<IActionResult> GetById(string id)
        {
            var major = await _service.GetByIdAsync(id);
            if (major == null) return NotFound();
            return Ok(major);
        }

        [HttpGet("by-faculty/{facultyId}")]
        [Authorize(Roles = "Admin,Student,Lecturer,Advisor")] // ✅ Cho phép tất cả roles đã authenticated (bao gồm Advisor)
        public async Task<IActionResult> GetByFaculty(string facultyId)
        {
            var list = await _service.GetByFacultyAsync(facultyId);
            return Ok(list);
        }

        [HttpPost]
        [Authorize(Roles = "Admin")] // ✅ Chỉ Admin được tạo
        public async Task<IActionResult> Create([FromBody] Major model)
        {
            try
            {
                await _service.AddAsync(model);

                // ✅ Audit Log: Create Major
                await LogCreateAsync("Major", model.MajorId, new {
                    major_code = model.MajorCode,
                    major_name = model.MajorName,
                    faculty_id = model.FacultyId
                });

                return Ok(new { message = "Thêm ngành học thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")] // ✅ Chỉ Admin được cập nhật
        public async Task<IActionResult> Update(string id, [FromBody] Major model)
        {
            if (id != model.MajorId)
                return BadRequest(new { message = "ID không khớp!" });

            var oldMajor = await _service.GetByIdAsync(id);
            await _service.UpdateAsync(model);

            // ✅ Audit Log: Update Major
            if (oldMajor != null)
            {
                await LogUpdateAsync("Major", model.MajorId,
                    new { major_name = oldMajor.MajorName, faculty_id = oldMajor.FacultyId },
                    new { major_name = model.MajorName, faculty_id = model.FacultyId });
            }

            return Ok(new { message = "Cập nhật ngành học thành công!" });
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")] // ✅ Chỉ Admin được xóa
        public async Task<IActionResult> Delete(string id)
        {
            var major = await _service.GetByIdAsync(id);
            await _service.DeleteAsync(id);

            // ✅ Audit Log: Delete Major
            if (major != null)
            {
                await LogDeleteAsync("Major", id, new {
                    major_code = major.MajorCode,
                    major_name = major.MajorName
                });
            }

            return Ok(new { message = "Xóa ngành học thành công!" });
        }
    }
}
