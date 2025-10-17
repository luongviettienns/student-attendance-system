    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.EntityFrameworkCore;
    using System.Security.Claims;
    using EducationManagement.DAL;

    namespace EducationManagement.API.Admin.Controllers
    {
        [ApiController]
        [Authorize] // ✅ Cho phép mọi user đăng nhập (Admin, Teacher, Student, Advisor)
        [Route("api-edu/menu")] // ✅ Route thống nhất toàn hệ thống
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
                        return Unauthorized(new { message = "Không xác định được vai trò người dùng." });
                    }

                    // 🔍 Lấy quyền theo RoleName
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
                            p.Icon
                        }
                    ).ToListAsync();

                    if (!permissions.Any())
                    {
                        return Ok(new { role = roleName, menus = new List<object>() });
                    }

                    // ✅ Xây dựng cây menu cha - con (theo ParentCode)
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

                    return Ok(new
                    {
                        role = roleName,
                        menus = menuTree
                    });
                }
                catch (Exception ex)
                {
                    return StatusCode(500, new { message = "Đã xảy ra lỗi khi lấy menu.", error = ex.Message });
                }
            }

            // ============================================================
            // 🔧 Helper: Format PermissionCode → State FE
            // ============================================================
            private static string FormatState(string code)
            {
                if (string.IsNullOrEmpty(code))
                    return null;

                // Xác định prefix FE theo vai trò
                string prefix = code.StartsWith("TEACHER_", StringComparison.OrdinalIgnoreCase) ? "main.teacher." :
                                code.StartsWith("STUDENT_", StringComparison.OrdinalIgnoreCase) ? "main.student." :
                                code.StartsWith("ADVISOR_", StringComparison.OrdinalIgnoreCase) ? "main.advisor." :
                                "main.admin."; // mặc định admin

                // Loại bỏ tiền tố role_
                string raw = code;
                foreach (var rolePrefix in new[] { "ADMIN_", "TEACHER_", "STUDENT_", "ADVISOR_" })
                {
                    if (raw.StartsWith(rolePrefix, StringComparison.OrdinalIgnoreCase))
                    {
                        raw = raw.Substring(rolePrefix.Length);
                        break;
                    }
                }

                // Chuyển sang lowercase & thay "_" bằng "."
                string formatted = raw.ToLower().Replace("_", ".");

                // Thêm prefix
                string fullState = prefix + formatted;

                // Gộp 2 phần cuối (vd: user.account → userAccount)
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
