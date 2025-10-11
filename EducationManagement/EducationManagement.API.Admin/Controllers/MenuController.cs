using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize] // ✅ tất cả user đã đăng nhập đều gọi được, menu sẽ lọc theo role
    [Route("api/admin/menu")]
    public class MenuController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MenuController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// 🔹 Lấy danh sách menu tương ứng với vai trò của user hiện tại
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetMenuForCurrentUser()
        {
            // 🔍 Đọc claim role từ token (ưu tiên "role" -> ClaimTypes.Role)
            var roleName = User.FindFirst("role")?.Value
                ?? User.FindFirst(ClaimTypes.Role)?.Value;

            if (string.IsNullOrEmpty(roleName))
            {
                Console.WriteLine("[MenuController] ❌ Không tìm thấy role trong token");
                return Unauthorized(new { message = "Không xác định được vai trò người dùng" });
            }

            Console.WriteLine($"[MenuController] ✅ Role from token = {roleName}");

            // 🔍 Lấy danh sách quyền tương ứng role
            var permissions = await (
                from rp in _context.RolePermissions
                join p in _context.Permissions on rp.PermissionId equals p.PermissionId
                join r in _context.Roles on rp.RoleId equals r.RoleId
                where r.RoleName.ToLower() == roleName.ToLower()
                      && p.IsActive && p.DeletedAt == null
                      && r.DeletedAt == null
                select new
                {
                    p.PermissionCode,
                    p.PermissionName,
                    p.Description
                }
            ).ToListAsync();

            Console.WriteLine($"[MenuController] 🔹 Found {permissions.Count} permissions for {roleName}");

            return Ok(new { role = roleName, menus = permissions });
        }
    }
}
