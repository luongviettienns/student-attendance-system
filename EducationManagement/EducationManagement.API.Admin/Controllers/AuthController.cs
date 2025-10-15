using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs;
using EducationManagement.Common.DTOs.User;
using EducationManagement.Common.Models;
using EducationManagement.Common.Helpers;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;
        private readonly JwtService _jwtService;

        public AuthController(AuthService authService, JwtService jwtService)
        {
            _authService = authService;
            _jwtService = jwtService;
        }

        #region 🔹 LOGIN (Không cần xác thực)
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // 🔹 Validate input
            if (request == null ||
                string.IsNullOrWhiteSpace(request.Username) ||
                string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Vui lòng nhập đầy đủ tài khoản và mật khẩu" });
            }

            // 🔹 Kiểm tra tài khoản
            var user = await _authService.ValidateUserAsync(request.Username, request.Password);
            if (user == null)
                return Unauthorized(new { message = "Sai tài khoản hoặc mật khẩu" });

            // 🔹 Sinh token
            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();
            await _authService.SaveRefreshTokenAsync(user.UserId, refreshToken);

            // 🔹 Thư mục chứa avatar
            var avatarFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";

            // 🔹 Lấy đường dẫn vật lý đến ảnh của user
            string avatarPath = user.AvatarUrl;
            string fileName = string.IsNullOrEmpty(avatarPath)
                ? string.Empty
                : Path.GetFileName(avatarPath);

            string physicalPath = string.IsNullOrEmpty(fileName)
                ? string.Empty
                : Path.Combine(avatarFolder, fileName);

            // 🔹 Nếu không có avatar hoặc file không tồn tại → fallback về default.png
            if (string.IsNullOrEmpty(fileName) || !System.IO.File.Exists(physicalPath))
            {
                avatarPath = "/avatars/default.png";
            }
            else
            {
                // Đảm bảo đường dẫn public khớp /avatars/
                avatarPath = $"/avatars/{fileName}";
            }

            // 🔹 Tạo URL đầy đủ cho FE
            string fullAvatarUrl = FileHelper.BuildFullAvatarUrl(
                Request.Scheme,
                Request.Host.ToString(),
                avatarPath
            );

            // 🔹 Chuẩn bị response
            var response = new LoginResponse
            {
                Token = accessToken,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt.ToUniversalTime(),
                UserId = user.UserId,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "User",
                FullName = user.FullName ?? string.Empty,
                AvatarUrl = fullAvatarUrl
            };

            return Ok(new { data = response });
        }
        #endregion

        #region 🔹 REFRESH TOKEN (Không cần xác thực)
        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.RefreshToken))
                return BadRequest(new { message = "Thiếu refresh token" });

            var oldRefreshToken = await _authService.GetRefreshTokenAsync(request.RefreshToken);
            if (oldRefreshToken == null || !oldRefreshToken.IsActive)
                return Unauthorized(new { message = "Refresh token không hợp lệ hoặc đã hết hạn" });

            var user = await _authService.GetUserByIdAsync(oldRefreshToken.UserId);
            if (user == null)
                return Unauthorized(new { message = "Không tìm thấy user" });

            var newAccessToken = _jwtService.GenerateAccessToken(user);
            var newRefreshToken = _jwtService.GenerateRefreshToken();

            await _authService.RevokeRefreshTokenAsync(oldRefreshToken.Id);
            await _authService.SaveRefreshTokenAsync(user.UserId, newRefreshToken);

            return Ok(new
            {
                Token = newAccessToken,
                RefreshToken = newRefreshToken.Token,
                RefreshTokenExpiry = newRefreshToken.ExpiresAt
            });
        }
        #endregion

        #region 🔹 LOGOUT (Yêu cầu xác thực)
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] RefreshRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.RefreshToken))
                return BadRequest(new { message = "Thiếu refresh token" });

            var refreshToken = await _authService.GetRefreshTokenAsync(request.RefreshToken);
            if (refreshToken != null)
                await _authService.RevokeRefreshTokenAsync(refreshToken.Id);

            return Ok(new { message = "Đã logout thành công" });
        }
        #endregion
    }
}
