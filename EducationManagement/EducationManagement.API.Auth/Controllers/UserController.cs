using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EducationManagement.DAL;                // AppDbContext
using EducationManagement.Common.Models;      // User entity
using System.Security.Claims;
using EducationManagement.Common.DTOs.User;


namespace EducationManagement.API.Auth.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/users")]
    public class UserController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly AppDbContext _context;

        public UserController(IWebHostEnvironment env, AppDbContext context)
        {
            _env = env;
            _context = context;
        }

        // ✅ GET: api/users/me → lấy profile từ token
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "Token không hợp lệ" });

            var user = await _context.Users.AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
                return NotFound(new { message = "Không tìm thấy user" });

            return Ok(MapToDto(user));
        }

        // ✅ PUT: api/users/me → update profile + avatar trong 1 request
        [HttpPut("me")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UpdateProfile([FromForm] UserUpdateRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "Token không hợp lệ" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy user" });

            // Update thông tin cơ bản
            user.FullName = request.FullName;
            user.Email = request.Email;
            user.Phone = request.Phone;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = userId;

            var webRoot = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadsFolder = Path.Combine(webRoot, "uploads", "avatars");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            // Nếu có upload avatar mới
            if (request.Avatar != null && request.Avatar.Length > 0)
            {
                // Xóa avatar cũ (nếu không phải default)
                if (!string.IsNullOrEmpty(user.AvatarUrl) && !user.AvatarUrl.EndsWith("default.png"))
                {
                    var oldFilePath = Path.Combine(webRoot, user.AvatarUrl.TrimStart('/'));
                    if (System.IO.File.Exists(oldFilePath))
                    {
                        try { System.IO.File.Delete(oldFilePath); } catch { }
                    }
                }

                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(request.Avatar.FileName)}";
                var filePath = Path.Combine(uploadsFolder, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await request.Avatar.CopyToAsync(stream);
                }

                user.AvatarUrl = $"/uploads/avatars/{fileName}";
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Cập nhật thành công",
                avatarUrl = GetFullAvatarUrl(user.AvatarUrl)
            });
        }

        // 📌 Request model để nhận FormData
        public class UserUpdateRequest
        {
            public string FullName { get; set; }
            public string Email { get; set; }
            public string Phone { get; set; }
            public IFormFile Avatar { get; set; }
        }

        // 📌 Map entity -> DTO (luôn trả avatarUrl đầy đủ)
        private UserResponseDto MapToDto(User user)
        {
            return new UserResponseDto
            {
                UserId = user.UserId,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                AvatarUrl = GetFullAvatarUrl(user.AvatarUrl)
            };
        }

        // 📌 Helper để build URL avatar đầy đủ
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