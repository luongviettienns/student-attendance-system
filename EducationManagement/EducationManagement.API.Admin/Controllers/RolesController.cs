using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api/admin/roles")]
    public class RoleController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RoleController(AppDbContext context)
        {
            _context = context;
        }

        #region 🔹 GET: Danh sách và chi tiết
        /// <summary>
        /// Lấy danh sách tất cả vai trò (Role)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var roles = await _context.Roles
                .Where(r => r.DeletedAt == null)
                .OrderBy(r => r.RoleName)
                .Select(r => new
                {
                    r.RoleId,
                    r.RoleName,
                    r.Description,
                    r.IsActive,
                    r.CreatedAt,
                    r.UpdatedAt
                })
                .ToListAsync();

            return Ok(new { data = roles });
        }

        /// <summary>
        /// Lấy chi tiết 1 vai trò theo ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var role = await _context.Roles
                .FirstOrDefaultAsync(r => r.RoleId == id && r.DeletedAt == null);

            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            return Ok(new { data = role });
        }
        #endregion

        #region 🔹 POST: Tạo Role mới
        /// <summary>
        /// Tạo mới một vai trò (Role)
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Role request)
        {
            if (string.IsNullOrWhiteSpace(request.RoleName))
                return BadRequest(new { message = "Tên vai trò không được để trống" });

            if (await _context.Roles.AnyAsync(r => r.RoleName == request.RoleName && r.DeletedAt == null))
                return BadRequest(new { message = "Tên vai trò đã tồn tại" });

            request.RoleId = Guid.NewGuid().ToString();
            request.CreatedAt = DateTime.UtcNow;
            request.CreatedBy = User.FindFirstValue(ClaimTypes.NameIdentifier);
            request.IsActive = true;

            _context.Roles.Add(request);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Tạo vai trò thành công",
                data = new { request.RoleId, request.RoleName }
            });
        }
        #endregion

        #region 🔹 PUT: Cập nhật Role
        /// <summary>
        /// Cập nhật thông tin vai trò theo ID
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] Role request)
        {
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleId == id && r.DeletedAt == null);
            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            if (await _context.Roles.AnyAsync(r => r.RoleName == request.RoleName && r.RoleId != id && r.DeletedAt == null))
                return BadRequest(new { message = "Tên vai trò đã tồn tại" });

            role.RoleName = request.RoleName;
            role.Description = request.Description;
            role.UpdatedAt = DateTime.UtcNow;
            role.UpdatedBy = User.FindFirstValue(ClaimTypes.NameIdentifier);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật vai trò thành công" });
        }
        #endregion

        #region 🔹 DELETE: Xoá mềm Role
        /// <summary>
        /// Xoá mềm vai trò (đặt DeletedAt và IsActive = false)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleId == id && r.DeletedAt == null);
            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            role.DeletedAt = DateTime.UtcNow;
            role.DeletedBy = User.FindFirstValue(ClaimTypes.NameIdentifier);
            role.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xoá vai trò thành công" });
        }
        #endregion

        #region 🔹 PUT: Bật/Tắt trạng thái hoạt động
        /// <summary>
        /// Chuyển trạng thái kích hoạt (active/inactive) cho Role
        /// </summary>
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleStatus(string id)
        {
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleId == id && r.DeletedAt == null);
            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            role.IsActive = !role.IsActive;
            role.UpdatedAt = DateTime.UtcNow;
            role.UpdatedBy = User.FindFirstValue(ClaimTypes.NameIdentifier);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"Đã {(role.IsActive ? "kích hoạt" : "vô hiệu hóa")} vai trò thành công",
                isActive = role.IsActive
            });
        }
        #endregion
    }
}
