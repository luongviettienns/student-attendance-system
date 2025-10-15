using System;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.DAL;
using Microsoft.EntityFrameworkCore;
using EducationManagement.Common.Models;

namespace EducationManagement.BLL.Services
{
    public class AuthService
    {
        private readonly AppDbContext _context;
        private readonly IRefreshTokenStore _refreshStore;

        public AuthService(AppDbContext context, IRefreshTokenStore refreshStore)
        {
            _context = context;
            _refreshStore = refreshStore;
        }

        // 🔹 Kiểm tra thông tin đăng nhập (đã tối ưu)
        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var stopwatch = System.Diagnostics.Stopwatch.StartNew();

            var normalizedUsername = username.Trim().ToLower();

            // ✅ Chỉ lấy các cột cần thiết, không Include toàn bộ Role
            var user = await _context.Users
                .Where(u => u.IsActive && u.Username.ToLower() == normalizedUsername)
                .Select(u => new User
                {
                    UserId = u.UserId,
                    Username = u.Username,
                    PasswordHash = u.PasswordHash,
                    FullName = u.FullName,
                    AvatarUrl = u.AvatarUrl,
                    Role = new Role { RoleName = u.Role.RoleName }
                })
                .AsNoTracking()
                .FirstOrDefaultAsync();

            if (user == null)
            {
                Console.WriteLine($"[Login] ❌ User không tồn tại ({stopwatch.ElapsedMilliseconds} ms)");
                return null;
            }

            // ✅ Kiểm tra mật khẩu (BCrypt)
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
            return await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);
        }
    }
}
