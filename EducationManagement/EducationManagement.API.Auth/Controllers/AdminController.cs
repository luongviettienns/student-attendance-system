using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EducationManagement.DAL;
using EducationManagement.Common.Models;
using EducationManagement.Common.DTOs.User;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Identity;

namespace EducationManagement.API.Auth.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/users")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _env;

        public AdminController(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        // ✅ GET: api/admin/users - Lấy danh sách tất cả users
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

            // Filter by search term
            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(u => 
                    u.Username.Contains(search) ||
                    u.FullName.Contains(search) ||
                    u.Email.Contains(search));
            }

            // Filter by role
            if (!string.IsNullOrEmpty(roleId))
            {
                query = query.Where(u => u.RoleId == roleId);
            }

            // Filter by active status
            if (isActive.HasValue)
            {
                query = query.Where(u => u.IsActive == isActive.Value);
            }

            // Get total count
            var totalCount = await query.CountAsync();

            // Apply pagination
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
                    AvatarUrl = u.AvatarUrl, // Store raw URL first
                    IsActive = u.IsActive,
                    LastLoginAt = u.LastLoginAt,
                    CreatedAt = u.CreatedAt,
                    CreatedBy = u.CreatedBy,
                    UpdatedAt = u.UpdatedAt,
                    UpdatedBy = u.UpdatedBy
                })
                .ToListAsync();

            // Process AvatarUrl after query execution
            foreach (var user in users)
            {
                user.AvatarUrl = GetFullAvatarUrl(user.AvatarUrl);
            }

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

        // ✅ GET: api/admin/users/{id} - Lấy thông tin user theo ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(string id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == id && u.DeletedAt == null);

            if (user == null)
                return NotFound(new { message = "User not found" });

            var userDto = new UserListDto
            {
                UserId = user.UserId,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                RoleName = user.Role.RoleName,
                AvatarUrl = GetFullAvatarUrl(user.AvatarUrl),
                IsActive = user.IsActive,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt,
                CreatedBy = user.CreatedBy,
                UpdatedAt = user.UpdatedAt,
                UpdatedBy = user.UpdatedBy
            };

            return Ok(userDto);
        }

        // ✅ POST: api/admin/users - Tạo user mới
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] UserCreateDto request)
        {
            // Check if username already exists
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                return BadRequest(new { message = "Username already exists" });

            // Check if email already exists
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                return BadRequest(new { message = "Email already exists" });

            // Check if role exists
            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                return BadRequest(new { message = "Invalid role ID" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var userId = Guid.NewGuid().ToString();

            var user = new User
            {
                UserId = userId,
                Username = request.Username,
                PasswordHash = HashPassword(request.Password),
                FullName = request.FullName,
                Email = request.Email,
                Phone = request.Phone,
                RoleId = request.RoleId,
                IsActive = request.IsActive,
                AvatarUrl = "/uploads/avatars/default.png",
                CreatedAt = DateTime.UtcNow,
                CreatedBy = currentUserId
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUserById), new { id = userId }, new
            {
                message = "User created successfully",
                userId = userId
            });
        }

        // ✅ PUT: api/admin/users/{id} - Cập nhật user
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, [FromBody] UserUpdateAdminDto request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            // Check if email already exists (excluding current user)
            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.UserId != id))
                return BadRequest(new { message = "Email already exists" });

            // Check if role exists
            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                return BadRequest(new { message = "Invalid role ID" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            user.FullName = request.FullName;
            user.Email = request.Email;
            user.Phone = request.Phone;
            user.RoleId = request.RoleId;
            user.IsActive = request.IsActive;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = currentUserId;

            await _context.SaveChangesAsync();

            return Ok(new { message = "User updated successfully" });
        }

        // ✅ DELETE: api/admin/users/{id} - Xóa user (soft delete)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            // Prevent admin from deleting themselves
            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (user.UserId == currentUserId)
                return BadRequest(new { message = "Cannot delete your own account" });

            var currentTime = DateTime.UtcNow;
            user.DeletedAt = currentTime;
            user.DeletedBy = currentUserId;
            user.IsActive = false;

            await _context.SaveChangesAsync();

            return Ok(new { message = "User deleted successfully" });
        }

        // ✅ PUT: api/admin/users/{id}/toggle-status - Bật/tắt trạng thái user
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleUserStatus(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            // Prevent admin from deactivating themselves
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

        // ✅ PUT: api/admin/users/{id}/change-password - Đổi mật khẩu user
        [HttpPut("{id}/change-password")]
        public async Task<IActionResult> ChangeUserPassword(string id, [FromBody] UserChangePasswordDto request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "User not found" });

            // Verify current password
            if (!VerifyPassword(request.CurrentPassword, user.PasswordHash))
                return BadRequest(new { message = "Current password is incorrect" });

            user.PasswordHash = HashPassword(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = User.FindFirstValue(ClaimTypes.NameIdentifier);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Password changed successfully" });
        }

        // ✅ GET: api/admin/roles - Lấy danh sách roles
        [HttpGet("roles")]
        public async Task<IActionResult> GetRoles()
        {
            var roles = await _context.Roles
                .Where(r => r.DeletedAt == null && r.IsActive)
                .Select(r => new
                {
                    r.RoleId,
                    r.RoleName,
                    r.Description
                })
                .ToListAsync();

            return Ok(roles);
        }

        // Helper methods
        private string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(hashedBytes);
        }

        private bool VerifyPassword(string password, string hash)
        {
            var hashedPassword = HashPassword(password);
            return hashedPassword == hash;
        }

        private string GetFullAvatarUrl(string avatarUrl)
        {
            if (string.IsNullOrEmpty(avatarUrl))
            {
                avatarUrl = "/uploads/avatars/default.png";
            }
            return $"{Request.Scheme}://{Request.Host}{avatarUrl}";
        }
    }
}
