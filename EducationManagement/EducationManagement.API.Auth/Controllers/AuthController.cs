using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;
using EducationManagement.Common.DTOs;
using EducationManagement.Common.DTOs.User;
using EducationManagement.Common.Models;
using EducationManagement.API.Auth.Helpers; // ✅ thêm using mới
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.API.Auth.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;
        private readonly JwtService _jwtService;

        public AuthController(AuthService authService, JwtService jwtService)
        {
            _authService = authService;
            _jwtService = jwtService;
        }

        // ✅ Login: trả về AccessToken + RefreshToken + User info
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest(new { message = "Vui lòng nhập đầy đủ tài khoản và mật khẩu" });

            var user = await _authService.ValidateUserAsync(request.Username, request.Password);
            if (user == null)
                return Unauthorized(new { message = "Sai tài khoản hoặc mật khẩu" });

            // map sang DTO để sinh JWT
            var userDto = new UserResponseDto
            {
                UserId = user.UserId.ToString(),
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId.ToString(),
                RoleName = user.Role?.RoleName ?? "User",
                AvatarUrl = user.AvatarUrl
            };

            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();
            await _authService.SaveRefreshTokenAsync(user.UserId, refreshToken);

            // ✅ chuyển avatarUrl sang absolute URL
            var absoluteAvatarUrl = HttpContext.Request.ToAbsoluteUrl(
                user.AvatarUrl ?? "/uploads/avatars/default.png"
            );

            return Ok(new LoginResponse
            {
                Token = accessToken,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt,
                UserId = user.UserId,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "User",
                FullName = user.FullName ?? string.Empty,
                AvatarUrl = absoluteAvatarUrl // ✅ FE dùng luôn link đầy đủ
            });
        }

        // ✅ Refresh: cấp AccessToken mới khi hết hạn
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

            var userDto = new UserResponseDto
            {
                UserId = user.UserId.ToString(),
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId.ToString(),
                RoleName = user.Role?.RoleName ?? "User",
                AvatarUrl = user.AvatarUrl
            };

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

        // ✅ Logout: vô hiệu hóa refresh token
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] RefreshRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.RefreshToken))
                return BadRequest(new { message = "Thiếu refresh token" });

            var refreshToken = await _authService.GetRefreshTokenAsync(request.RefreshToken);
            if (refreshToken != null)
                await _authService.RevokeRefreshTokenAsync(refreshToken.Id);

            return Ok(new { message = "Đã logout" });
        }
    }
}
