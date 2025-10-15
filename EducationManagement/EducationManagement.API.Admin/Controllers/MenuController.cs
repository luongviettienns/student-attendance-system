using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;
using System.Text;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize]
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

        // ============================================================
        // 🔧 Hàm helper: tự động format PermissionCode -> FE State
        // ============================================================
        private static string FormatState(string code)
        {
            if (string.IsNullOrEmpty(code))
                return null;

            // 1️⃣ Xác định prefix FE dựa vào vai trò
            // (ADMIN_, TEACHER_, STUDENT_, ADVISOR_)
            string prefix = code.StartsWith("TEACHER_", StringComparison.OrdinalIgnoreCase) ? "main.teacher." :
                            code.StartsWith("STUDENT_", StringComparison.OrdinalIgnoreCase) ? "main.student." :
                            code.StartsWith("ADVISOR_", StringComparison.OrdinalIgnoreCase) ? "main.advisor." :
                            "main.admin."; // mặc định admin

            // 2️⃣ Loại bỏ tiền tố role_ khỏi code
            string raw = code;
            foreach (var rolePrefix in new[] { "ADMIN_", "TEACHER_", "STUDENT_", "ADVISOR_" })
            {
                if (raw.StartsWith(rolePrefix, StringComparison.OrdinalIgnoreCase))
                {
                    raw = raw.Substring(rolePrefix.Length);
                    break;
                }
            }

            // 3️⃣ Chuyển sang chữ thường, thay "_" bằng "."
            string formatted = raw.ToLower().Replace("_", ".");

            // 4️⃣ Thêm prefix
            string fullState = prefix + formatted;

            // 5️⃣ Gộp 2 phần cuối (ví dụ: user.account → userAccount)
            var parts = fullState.Split('.');
            if (parts.Length > 3)
            {
                var lastTwo = parts[^2] + char.ToUpper(parts[^1][0]) + parts[^1].Substring(1);
                fullState = string.Join(".", parts.Take(parts.Length - 2)) + "." + lastTwo;
            }

            return fullState;
        }
    }
}
