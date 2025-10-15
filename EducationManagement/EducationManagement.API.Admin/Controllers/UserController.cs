using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;
using EducationManagement.Common.Models;
using EducationManagement.Common.DTOs.User;
using EducationManagement.Common.Helpers;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize]
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

        #region 🔹 GET: Lấy thông tin user hiện tại (từ token)
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "Token không hợp lệ" });

            var user = await _context.Users
                .Include(u => u.Role)
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserId == userId && u.DeletedAt == null);

            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            var dto = MapToDto(user);
            return Ok(new { data = dto });
        }
        #endregion

        #region 🔹 PUT: Cập nhật thông tin + avatar (FormData)
        [HttpPut("me")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UpdateProfile([FromForm] UserUpdateRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "Token không hợp lệ" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            // ✅ Cập nhật thông tin cơ bản
            user.FullName = request.FullName;
            user.Email = request.Email;
            user.Phone = request.Phone;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = userId;

            // ✅ Thư mục lưu ảnh (giống Program.cs)
            var avatarFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";
            if (!Directory.Exists(avatarFolder))
                Directory.CreateDirectory(avatarFolder);

            // ✅ Xử lý upload avatar mới
            if (request.Avatar != null && request.Avatar.Length > 0)
            {
                var extension = Path.GetExtension(request.Avatar.FileName).ToLower();
                var fileName = $"{user.UserId}{extension}";
                var filePath = Path.Combine(avatarFolder, fileName);

                // Xóa file cũ nếu tồn tại
                if (System.IO.File.Exists(filePath))
                {
                    try { System.IO.File.Delete(filePath); } catch { }
                }

                // Lưu file mới
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await request.Avatar.CopyToAsync(stream);
                }

                // ✅ Lưu đường dẫn public (đúng với RequestPath = "/avatars")
                user.AvatarUrl = $"/avatars/{fileName}";
            }

            await _context.SaveChangesAsync();

            // ✅ Tạo URL đầy đủ để FE hiển thị đúng port Gateway
            var fullAvatarUrl = FileHelper.BuildFullAvatarUrl(Request.Scheme, Request.Host.ToString(), user.AvatarUrl);

            return Ok(new
            {
                message = "Cập nhật thông tin thành công",
                data = new { avatarUrl = fullAvatarUrl }
            });
        }
        #endregion

        #region 📌 DTO nội bộ cho cập nhật hồ sơ
        public class UserUpdateRequest
        {
            public string FullName { get; set; } = string.Empty;
            public string Email { get; set; } = string.Empty;
            public string Phone { get; set; } = string.Empty;
            public IFormFile? Avatar { get; set; }
        }
        #endregion

        #region 📌 Helper: Map entity → DTO
        private UserResponseDto MapToDto(User user)
        {
            // ✅ Chuẩn hóa đường dẫn cũ (nếu còn /uploads/avatars)
            string relativePath = user.AvatarUrl;

            if (!string.IsNullOrEmpty(relativePath))
            {
                if (relativePath.Contains("/uploads/avatars"))
                    relativePath = relativePath.Replace("/uploads/avatars", "/avatars");
            }
            else
            {
                relativePath = "/avatars/default.png";
            }

            return new UserResponseDto
            {
                UserId = user.UserId,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                RoleName = user.Role?.RoleName,
                AvatarUrl = FileHelper.BuildFullAvatarUrl(Request.Scheme, Request.Host.ToString(), relativePath)
            };
        }
        #endregion
    }
}
