using Microsoft.AspNetCore.Mvc;
using EducationManagement.DAL.Repositories;
using EducationManagement.Common.Models;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api-edu/admin/department")]
    public class DepartmentController : BaseController
    {
        private readonly DepartmentRepository _repository;

        public DepartmentController(DepartmentRepository repository, AuditLogService auditLogService) : base(auditLogService)
        {
            _repository = repository;
        }

        // ============================================================
        // 🔹 GET: Lấy danh sách tất cả bộ môn
        // ============================================================
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var departments = await _repository.GetAllAsync();
                return Ok(new { data = departments });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Lấy bộ môn theo ID
        // ============================================================
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var department = await _repository.GetByIdAsync(id);
                if (department == null)
                    return NotFound(new { message = "Không tìm thấy bộ môn" });

                return Ok(new { data = department });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Lấy bộ môn theo khoa
        // ============================================================
        [HttpGet("faculty/{facultyId}")]
        public async Task<IActionResult> GetByFaculty(string facultyId)
        {
            try
            {
                var allDepartments = await _repository.GetAllAsync();
                var departments = allDepartments.FindAll(d => d.FacultyId == facultyId);
                return Ok(new { data = departments });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 POST: Tạo bộ môn mới
        // ============================================================
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Department model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                // Generate ID if not provided
                if (string.IsNullOrEmpty(model.DepartmentId))
                    model.DepartmentId = "dep-" + Guid.NewGuid().ToString().Substring(0, 8);

                model.CreatedBy = User.Identity?.Name ?? "system";
                model.CreatedAt = DateTime.Now;

                await _repository.AddAsync(model);

                // ✅ Audit Log: Create Department
                await LogCreateAsync("Department", model.DepartmentId, new {
                    department_code = model.DepartmentCode,
                    department_name = model.DepartmentName,
                    faculty_id = model.FacultyId
                });

                return Ok(new { message = "✅ Thêm bộ môn thành công!", data = model });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 PUT: Cập nhật bộ môn
        // ============================================================
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Department model)
        {
            if (id != model.DepartmentId)
                return BadRequest(new { message = "ID không khớp!" });

            try
            {
                var oldDept = await _repository.GetByIdAsync(id);
                
                model.UpdatedBy = User.Identity?.Name ?? "system";
                model.UpdatedAt = DateTime.Now;

                var rowsAffected = await _repository.UpdateAsync(model);
                if (rowsAffected == 0)
                    return NotFound(new { message = "Không tìm thấy bộ môn" });

                // ✅ Audit Log: Update Department
                if (oldDept != null)
                {
                    await LogUpdateAsync("Department", model.DepartmentId,
                        new { department_name = oldDept.DepartmentName, faculty_id = oldDept.FacultyId },
                        new { department_name = model.DepartmentName, faculty_id = model.FacultyId });
                }

                return Ok(new { message = "✅ Cập nhật bộ môn thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 DELETE: Xóa bộ môn (soft delete)
        // ============================================================
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                var dept = await _repository.GetByIdAsync(id);
                await _repository.DeleteAsync(id);

                // ✅ Audit Log: Delete Department
                if (dept != null)
                {
                    await LogDeleteAsync("Department", id, new {
                        department_code = dept.DepartmentCode,
                        department_name = dept.DepartmentName
                    });
                }

                return Ok(new { message = "🗑 Xóa bộ môn thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Thống kê số môn học theo bộ môn
        // ============================================================
        [HttpGet("stats/subjects")]
        public async Task<IActionResult> GetSubjectStats()
        {
            try
            {
                // TODO: Implement stored procedure for statistics
                return Ok(new { data = new List<object>(), message = "Chức năng đang phát triển" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Thống kê số giảng viên theo bộ môn
        // ============================================================
        [HttpGet("stats/lecturers")]
        public async Task<IActionResult> GetLecturerStats()
        {
            try
            {
                // TODO: Implement stored procedure for statistics
                return Ok(new { data = new List<object>(), message = "Chức năng đang phát triển" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}
