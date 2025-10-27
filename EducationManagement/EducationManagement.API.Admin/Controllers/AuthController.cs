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
    [Route("api-edu/auth")]
    public class AuthController : BaseController
    {
        private readonly AuthService _authService;
        private readonly JwtService _jwtService;
        private readonly string _avatarFolder;
        private readonly string _gatewayUrl;

        public AuthController(
            AuthService authService, 
            JwtService jwtService, 
            IConfiguration configuration,
            AuditLogService auditLogService) : base(auditLogService)
        {
            _authService = authService;
            _jwtService = jwtService;
            
            // ✅ Dùng Gateway URL (Microservices pattern)
            _gatewayUrl = configuration["GatewayUrl"] ?? "https://localhost:7033";

            // ✅ Xác định thư mục chứa avatar
            var projectRoot = Directory.GetParent(Directory.GetCurrentDirectory())?.FullName;
            _avatarFolder = Path.Combine(projectRoot!, "Avatar_User");

            if (!Directory.Exists(_avatarFolder))
                Directory.CreateDirectory(_avatarFolder);

            Console.WriteLine($"🧭 Avatar folder path: {_avatarFolder}");
            Console.WriteLine($"🌐 Gateway URL (Microservices): {_gatewayUrl}");
        }

        // ============================================================
        // 🔹 LOGIN
        // ============================================================
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null ||
                string.IsNullOrWhiteSpace(request.Username) ||
                string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Vui lòng nhập đầy đủ tài khoản và mật khẩu" });
            }

            var user = await _authService.ValidateUserAsync(request.Username, request.Password);
            if (user == null)
                return Unauthorized(new { message = "Sai tài khoản hoặc mật khẩu" });

            // ✅ Sinh token
            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();
            await _authService.SaveRefreshTokenAsync(user.UserId, refreshToken);

            // ✅ Chuẩn hóa đường dẫn avatar
            string avatarPath = FileHelper.NormalizeAvatarUrl(user.AvatarUrl, _avatarFolder);
            
            // ✅ Build full URL qua Gateway (Microservices pattern)
            // Frontend sẽ load từ Gateway: https://localhost:7033/avatars/user-001.jpg
            // Gateway sẽ proxy request đến Admin API:5227
            string fullAvatarUrl = $"{_gatewayUrl}{avatarPath}";

            // ✅ Tạo response
            var response = new LoginResponse
            {
                Token = accessToken,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt.ToUniversalTime(),
                UserId = user.UserId,
                Username = user.Username,
                Role = user.RoleName ?? "User",
                FullName = user.FullName ?? string.Empty,
                AvatarUrl = fullAvatarUrl
            };

            // ✅ Audit Log: Login
            await LogLoginAsync(user.UserId, new { 
                username = user.Username, 
                role = user.RoleName,
                login_time = DateTime.UtcNow 
            });

            // Console.WriteLine($"[Login] ✅ {user.Username} đăng nhập thành công"); // Tắt để tránh spam log
            return Ok(new { data = response });
        }

        // ============================================================
        // 🔹 REFRESH TOKEN
        // ============================================================
        [HttpPost("refresh")]
        [AllowAnonymous]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.RefreshToken))
                return BadRequest(new { message = "Thiếu refresh token" });

            var oldToken = await _authService.GetRefreshTokenAsync(request.RefreshToken);
            if (oldToken == null || !oldToken.IsActive)
                return Unauthorized(new { message = "Refresh token không hợp lệ hoặc đã hết hạn" });

            var user = await _authService.GetUserByIdAsync(oldToken.UserId);
            if (user == null)
                return Unauthorized(new { message = "Không tìm thấy người dùng" });

            // ✅ Tạo token mới
            var newAccessToken = _jwtService.GenerateAccessToken(user);
            var newRefreshToken = _jwtService.GenerateRefreshToken();

            await _authService.RevokeRefreshTokenAsync(oldToken.Id);
            await _authService.SaveRefreshTokenAsync(user.UserId, newRefreshToken);

            return Ok(new
            {
                Token = newAccessToken,
                RefreshToken = newRefreshToken.Token,
                RefreshTokenExpiry = newRefreshToken.ExpiresAt
            });
        }

        // ============================================================
        // 🔹 LOGOUT
        // ============================================================
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] RefreshRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.RefreshToken))
                return BadRequest(new { message = "Thiếu refresh token" });

            var token = await _authService.GetRefreshTokenAsync(request.RefreshToken);
            if (token != null)
            {
                await _authService.RevokeRefreshTokenAsync(token.Id);
                
                // ✅ Audit Log: Logout
                await LogLogoutAsync(token.UserId);
            }

            // Console.WriteLine($"[Logout] ✅ Token đã bị thu hồi"); // Tắt để tránh spam log
            return Ok(new { message = "Đăng xuất thành công" });
        }
    }
}
