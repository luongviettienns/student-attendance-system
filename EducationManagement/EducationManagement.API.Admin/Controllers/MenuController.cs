using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize] // ✅ Chỉ cho phép user đã đăng nhập
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
            try
            {
                // 🔍 Lấy role từ token
                var roleName = User.FindFirst("role")?.Value
                    ?? User.FindFirst(ClaimTypes.Role)?.Value;

                if (string.IsNullOrEmpty(roleName))
                {
                    Console.WriteLine("[MenuController] ❌ Không tìm thấy role trong token");
                    return Unauthorized(new { message = "Không xác định được vai trò người dùng" });
                }

                Console.WriteLine($"[MenuController] ✅ Role from token = {roleName}");

                // 🔍 Lấy danh sách quyền từ DB
                var permissions = await (
                    from rp in _context.RolePermissions
                    join p in _context.Permissions on rp.PermissionId equals p.PermissionId
                    join r in _context.Roles on rp.RoleId equals r.RoleId
                    where r.RoleName.ToLower() == roleName.ToLower()
                          && p.IsActive
                          && p.DeletedAt == null
                          && r.DeletedAt == null
                    orderby p.SortOrder, p.PermissionName
                    select new
                    {
                        p.PermissionId,
                        p.PermissionCode,
                        p.PermissionName,
                        p.ParentCode,
                        p.Icon,
                        p.Description
                    }
                ).ToListAsync();

                if (permissions == null || !permissions.Any())
                {
                    Console.WriteLine($"[MenuController] ⚠️ Role '{roleName}' không có quyền nào");
                    return Ok(new { role = roleName, menus = new List<object>() });
                }

                // ✅ Tạo cây menu cha - con (dropdown)
                var menuTree = permissions
                    .Where(p => string.IsNullOrEmpty(p.ParentCode))
                    .Select(parent => new
                    {
                        label = parent.PermissionName,
                        icon = string.IsNullOrWhiteSpace(parent.Icon) ? "fa fa-circle" : parent.Icon,
                        state = FormatState(parent.PermissionCode),
                        sub = permissions
                            .Where(child => child.ParentCode == parent.PermissionCode)
                            .Select(child => new
                            {
                                label = child.PermissionName,
                                icon = string.IsNullOrWhiteSpace(child.Icon) ? "fa fa-angle-right" : child.Icon,
                                state = FormatState(child.PermissionCode)
                            })
                            .ToList()
                    })
                    .ToList();

                Console.WriteLine($"[MenuController] 🔹 Found {menuTree.Count} menu groups for role '{roleName}'");

                return Ok(new
                {
                    role = roleName,
                    menus = menuTree
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[MenuController] ❌ Lỗi không mong đợi: {ex.Message}");
                return StatusCode(500, new { message = "Đã xảy ra lỗi khi lấy menu.", error = ex.Message });
            }
        }

        // 🔧 Hàm helper: format state cho FE
        private static string FormatState(string code)
        {
            return string.IsNullOrEmpty(code)
                ? null
                : code.ToLower().Replace("_", ".");
        }
    }
}
