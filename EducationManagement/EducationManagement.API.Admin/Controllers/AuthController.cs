using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs;
using EducationManagement.Common.DTOs.User;
using EducationManagement.Common.Models;

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
        /// <summary>
        /// Đăng nhập hệ thống - trả về AccessToken + RefreshToken + thông tin người dùng
        /// </summary>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { message = "Vui lòng nhập đầy đủ tài khoản và mật khẩu" });

            var user = await _authService.ValidateUserAsync(request.Username, request.Password);
            if (user == null)
                return Unauthorized(new { message = "Sai tài khoản hoặc mật khẩu" });

            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();
            await _authService.SaveRefreshTokenAsync(user.UserId, refreshToken);

            return Ok(new LoginResponse
            {
                Token = accessToken,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt,
                UserId = user.UserId,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "User",
                FullName = user.FullName ?? string.Empty,
                AvatarUrl = user.AvatarUrl ?? "/uploads/avatars/default.png"

            });
        }
        #endregion

        #region 🔹 REFRESH TOKEN (Không cần xác thực)
        /// <summary>
        /// Cấp mới AccessToken khi hết hạn, dùng RefreshToken cũ
        /// </summary>
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
        /// <summary>
        /// Đăng xuất - vô hiệu hóa RefreshToken hiện tại
        /// </summary>
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
