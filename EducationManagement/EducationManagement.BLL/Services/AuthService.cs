using System;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.DAL.Repositories;
using EducationManagement.Common.Models;

namespace EducationManagement.BLL.Services
{
    public class AuthService
    {
        private readonly UserRepository _userRepository;
        private readonly IRefreshTokenStore _refreshStore;

        public AuthService(UserRepository userRepository, IRefreshTokenStore refreshStore)
        {
            _userRepository = userRepository;
            _refreshStore = refreshStore;
        }

        // 🔹 Kiểm tra thông tin đăng nhập (đã tối ưu)
        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();

            var normalizedUsername = username.Trim().ToLower();

            // ✅ Lấy user từ repository
            var user = await _userRepository.GetByUsernameAsync(normalizedUsername);

            if (user == null || !user.IsActive)
            {
                // Console.WriteLine($"[Login] ❌ User không tồn tại ({stopwatch.ElapsedMilliseconds} ms)"); // Tắt log
                return null;
            }

            // ✅ Kiểm tra mật khẩu (BCrypt)
            var isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
            // Console.WriteLine($"[Login] BCrypt.Verify mất {sw.ElapsedMilliseconds} ms"); // Tắt log timing

            stopwatch.Stop();

            if (!isValid)
            {
                // Console.WriteLine($"[Login] ❌ Sai mật khẩu ({stopwatch.ElapsedMilliseconds} ms)"); // Tắt log
                return null;
            }

            // Console.WriteLine($"[Login] ✅ Thành công, tổng {stopwatch.ElapsedMilliseconds} ms"); // Tắt log
            return user;
        }

        // 🔹 Hash mật khẩu dùng chung
        public string HashPassword(string password)
        {
            // ⚙️ Giảm work factor trong môi trường dev/test cho nhanh
            return BCrypt.Net.BCrypt.HashPassword(password, workFactor: 10);
        }

        // 🔹 Verify mật khẩu dùng chung
        public bool VerifyPassword(string password, string passwordHash)
        {
            return BCrypt.Net.BCrypt.Verify(password, passwordHash);
        }

        // 🔹 Lưu refresh token
        public async Task SaveRefreshTokenAsync(string userId, RefreshToken refreshToken)
        {
            await _refreshStore.SaveAsync(userId, refreshToken);
        }

        // 🔹 Lấy refresh token từ DB
        public async Task<RefreshToken?> GetRefreshTokenAsync(string token)
        {
            return await _refreshStore.GetByTokenAsync(token);
        }

        // 🔹 Revoke refresh token (đánh dấu không dùng nữa)
        public async Task RevokeRefreshTokenAsync(Guid id)
        {
            await _refreshStore.RevokeAsync(id);
        }

        // 🔹 Lấy thông tin user từ DB
        public async Task<User?> GetUserByIdAsync(string userId)
        {
            return await _userRepository.GetByIdAsync(userId);
        }
    }
}
