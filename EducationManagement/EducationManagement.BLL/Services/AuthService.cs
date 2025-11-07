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

        // 🔹 Kiểm tra thông tin đăng nhập
        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var normalizedUsername = username.Trim().ToLower();

            // ✅ Lấy user từ repository
            var user = await _userRepository.GetByUsernameAsync(normalizedUsername);

            if (user == null || !user.IsActive)
            {
<<<<<<< Updated upstream
                Console.WriteLine($"[Login] ❌ User không tồn tại ({stopwatch.ElapsedMilliseconds} ms)");
=======
>>>>>>> Stashed changes
                return null;
            }

            // ✅ Kiểm tra mật khẩu (BCrypt)
<<<<<<< Updated upstream
            var sw = System.Diagnostics.Stopwatch.StartNew();
            var isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
            sw.Stop();
            Console.WriteLine($"[Login] BCrypt.Verify mất {sw.ElapsedMilliseconds} ms");

            stopwatch.Stop();

            if (!isValid)
            {
                Console.WriteLine($"[Login] ❌ Sai mật khẩu ({stopwatch.ElapsedMilliseconds} ms)");
                return null;
            }

            Console.WriteLine($"[Login] ✅ Thành công, tổng {stopwatch.ElapsedMilliseconds} ms");
=======
            // 🔧 FIX: Trim hash để tránh trailing spaces từ database
            var passwordHash = user.PasswordHash?.Trim() ?? "";
            var isValid = BCrypt.Net.BCrypt.Verify(password, passwordHash);

            if (!isValid)
            {
                return null;
            }
            
>>>>>>> Stashed changes
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
            return await _userRepository.GetByIdAsync(userId);
        }
    }
}
