using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EducationManagement.DAL;
using EducationManagement.Common.DTOs.User;
using EducationManagement.BLL.Services;
using EducationManagement.Common.Helpers;
using System.Security.Claims;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/users")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly AuthService _authService;

        public AdminController(AppDbContext context, AuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        /* ============================================================
           📄 1. Lấy danh sách người dùng (phân trang, lọc, tìm kiếm)
        ============================================================ */
        [HttpGet]
        public async Task<IActionResult> GetAllUsers(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? roleId = null,
            [FromQuery] bool? isActive = null)
        {
            var query = _context.Users
                .Include(u => u.Role)
                .Where(u => u.DeletedAt == null)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(u =>
                    u.Username.Contains(search) ||
                    u.FullName.Contains(search) ||
                    u.Email.Contains(search));
            }

            if (!string.IsNullOrEmpty(roleId))
                query = query.Where(u => u.RoleId == roleId);

            if (isActive.HasValue)
                query = query.Where(u => u.IsActive == isActive.Value);

            var totalCount = await query.CountAsync();

            var users = await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new UserListDto
                {
                    UserId = u.UserId,
                    Username = u.Username,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone,
                    RoleId = u.RoleId,
                    RoleName = u.Role.RoleName,
                    AvatarUrl = FileHelper.BuildFullAvatarUrl(
                        Request.Scheme, Request.Host.ToString(), u.AvatarUrl),
                    IsActive = u.IsActive,
                    LastLoginAt = u.LastLoginAt,
                    CreatedAt = u.CreatedAt,
                    CreatedBy = u.CreatedBy,
                    UpdatedAt = u.UpdatedAt,
                    UpdatedBy = u.UpdatedBy
                })
                .ToListAsync();

            return Ok(new
            {
                users,
                pagination = new
                {
                    page,
                    pageSize,
                    totalCount,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                }
            });
        }

        /* ============================================================
           🔍 2. Lấy chi tiết người dùng theo ID
        ============================================================ */
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(string id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == id && u.DeletedAt == null);

            if (user == null)
                return NotFound(new { message = "User not found" });

            var dto = new UserListDto
            {
                UserId = user.UserId,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                RoleName = user.Role.RoleName,
                AvatarUrl = FileHelper.BuildFullAvatarUrl(
                    Request.Scheme, Request.Host.ToString(), user.AvatarUrl),
                IsActive = user.IsActive,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt,
                CreatedBy = user.CreatedBy,
                UpdatedAt = user.UpdatedAt,
                UpdatedBy = user.UpdatedBy
            };

            return Ok(dto);
        }

        /* ============================================================
           🚫 3. XÓA MỀM người dùng (Admin không được xóa thật)
        ============================================================ */
        [HttpDelete("{id}")]
        public async Task<IActionResult> SoftDeleteUser(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (user.UserId == currentUserId)
                return BadRequest(new { message = "Cannot delete your own account" });

            user.DeletedAt = DateTime.UtcNow;
            user.DeletedBy = currentUserId;
            user.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { message = "User soft-deleted successfully" });
        }

        /* ============================================================
           🔄 4. Bật / Tắt hoạt động tài khoản
        ============================================================ */
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleUserStatus(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (user.UserId == currentUserId)
                return BadRequest(new { message = "Cannot deactivate your own account" });

            user.IsActive = !user.IsActive;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = currentUserId;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"User {(user.IsActive ? "activated" : "deactivated")} successfully",
                isActive = user.IsActive
            });
        }
    }
}
