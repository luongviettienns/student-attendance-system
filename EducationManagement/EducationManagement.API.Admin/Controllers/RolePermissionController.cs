using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")] // ✅ Chỉ Admin được phép quản lý phân quyền
    [Route("api/admin/role-permissions")]
    public class RolePermissionController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RolePermissionController(AppDbContext context)
        {
            _context = context;
        }

        #region 🔹 GET: Lấy danh sách quyền của 1 Role
        /// <summary>
        /// Lấy danh sách quyền của một vai trò cụ thể
        /// </summary>
        [HttpGet("{roleId}")]
        public async Task<IActionResult> GetPermissionsByRole(string roleId)
        {
            var role = await _context.Roles
                .FirstOrDefaultAsync(r => r.RoleId == roleId && r.DeletedAt == null);

            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            var allPermissions = await _context.Permissions
                .Where(p => p.DeletedAt == null && p.IsActive)
                .Select(p => new
                {
                    p.PermissionId,
                    p.PermissionCode,
                    p.PermissionName,
                    p.Description
                })
                .ToListAsync();

            var rolePermIds = await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .Select(rp => rp.PermissionId)
                .ToListAsync();

            var result = allPermissions.Select(p => new
            {
                p.PermissionId,
                p.PermissionCode,
                p.PermissionName,
                p.Description,
                IsAssigned = rolePermIds.Contains(p.PermissionId)
            });

            return Ok(new
            {
                RoleId = role.RoleId,
                RoleName = role.RoleName,
                Permissions = result
            });
        }
        #endregion

        #region 🔹 POST: Gán quyền cho 1 Role
        /// <summary>
        /// Cập nhật danh sách quyền cho một vai trò (Admin only)
        /// </summary>
        [HttpPost("{roleId}")]
        public async Task<IActionResult> AssignPermissions(string roleId, [FromBody] List<string> permissionIds)
        {
            if (permissionIds == null)
                return BadRequest(new { message = "Danh sách quyền không hợp lệ" });

            var role = await _context.Roles
                .FirstOrDefaultAsync(r => r.RoleId == roleId && r.DeletedAt == null);

            if (role == null)
                return NotFound(new { message = "Không tìm thấy vai trò" });

            // Xóa quyền cũ
            var oldPermissions = _context.RolePermissions.Where(rp => rp.RoleId == roleId);
            _context.RolePermissions.RemoveRange(oldPermissions);

            // Thêm quyền mới
            var newRolePerms = permissionIds.Select(pid => new RolePermission
            {
                RoleId = roleId,
                PermissionId = pid,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = User.FindFirstValue(ClaimTypes.NameIdentifier)
            }).ToList();

            _context.RolePermissions.AddRange(newRolePerms);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật quyền thành công" });
        }
        #endregion

        #region 🔹 GET: Danh sách tất cả quyền hệ thống
        /// <summary>
        /// Lấy toàn bộ danh sách quyền trong hệ thống
        /// </summary>
        [HttpGet("all")]
        public async Task<IActionResult> GetAllPermissions()
        {
            var permissions = await _context.Permissions
                .Where(p => p.DeletedAt == null && p.IsActive)
                .Select(p => new
                {
                    p.PermissionId,
                    p.PermissionCode,
                    p.PermissionName,
                    p.Description
                })
                .OrderBy(p => p.PermissionName)
                .ToListAsync();

            return Ok(permissions);
        }
        #endregion
    }
}
