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
        private readonly CachingService? _cache;

        public AuthService(UserRepository userRepository, IRefreshTokenStore refreshStore, CachingService? cache = null)
        {
            _userRepository = userRepository;
            _refreshStore = refreshStore;
            _cache = cache;
        }

        // 🔹 Kiểm tra thông tin đăng nhập
        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var normalizedUsername = username.Trim().ToLower();

            // ✅ Lấy user từ repository (với caching nếu có)
            User? user;
            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.UserByUsername, normalizedUsername);
                user = await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _userRepository.GetByUsernameAsync(normalizedUsername),
                    CacheKeys.UserExpiration
                );
            }
            else
            {
                user = await _userRepository.GetByUsernameAsync(normalizedUsername);
            }

            if (user == null || !user.IsActive)
            {
                // Console.WriteLine($"[Login] ❌ User không tồn tại"); // Tắt log
                return null;
            }

            // ✅ Kiểm tra mật khẩu (BCrypt)
            // 🔧 FIX: Trim hash để tránh trailing spaces từ database
            var passwordHash = user.PasswordHash?.Trim() ?? "";
            var isValid = BCrypt.Net.BCrypt.Verify(password, passwordHash);
            // Console.WriteLine($"[Login] BCrypt.Verify"); // Tắt log timing

            if (!isValid)
            {
                // Console.WriteLine($"[Login] ❌ Sai mật khẩu"); // Tắt log
                return null;
            }

            // Console.WriteLine($"[Login] ✅ Thành công"); // Tắt log
            return user;
        }

        // 🔹 Hash mật khẩu dùng chung
        public string HashPassword(string password, int workFactor = 12)
        {
            // ⚙️ Work factor 12 để tương thích với hash cũ ($2b$12$)
            // Có thể giảm xuống 10 trong môi trường dev/test cho nhanh
            return BCrypt.Net.BCrypt.HashPassword(password, workFactor: workFactor);
        }

        // 🔹 Verify mật khẩu dùng chung
        public bool VerifyPassword(string password, string passwordHash)
        {
            // 🔧 FIX: Trim hash để tránh trailing spaces từ database
            var hash = passwordHash?.Trim() ?? "";
            return BCrypt.Net.BCrypt.Verify(password, hash);
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
            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.UserById, userId);
                return await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _userRepository.GetByIdAsync(userId),
                    CacheKeys.UserExpiration
                );
            }
            return await _userRepository.GetByIdAsync(userId);
        }

        // 🔹 Lấy thông tin user theo email (cho forgot password)
        public async Task<User?> GetUserByEmailAsync(string email)
        {
            var normalizedEmail = email.Trim().ToLower();
            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.UserByEmail, normalizedEmail);
                return await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _userRepository.GetByEmailAsync(email),
                    CacheKeys.UserExpiration
                );
            }
            return await _userRepository.GetByEmailAsync(email);
        }

        // 🔹 Cập nhật mật khẩu user
        public async Task<bool> UpdatePasswordAsync(string userId, string newPassword)
        {
            var result = await _userRepository.UpdatePasswordAsync(userId, HashPassword(newPassword));
            
            // Invalidate cache after password update
            if (_cache != null && result)
            {
                await _cache.RemoveAsync(string.Format(CacheKeys.UserById, userId));
            }
            
            return result;
        }
    }
}
