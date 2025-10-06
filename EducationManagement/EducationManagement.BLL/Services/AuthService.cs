using System;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.DAL;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
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

        // ✅ Kiểm tra thông tin đăng nhập
        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Username.ToLower() == username.ToLower() && u.IsActive);

            if (user == null) return null;

            // ⚡ Verify mật khẩu
            if (!BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                return null;

            return user;
        }

        // ✅ Hash mật khẩu dùng chung
        public string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        // ✅ Verify mật khẩu dùng chung
        public bool VerifyPassword(string password, string passwordHash)
        {
            return BCrypt.Net.BCrypt.Verify(password, passwordHash);
        }

        // ✅ Lưu refresh token
        public async Task SaveRefreshTokenAsync(string userId, RefreshToken refreshToken)
        {
            await _refreshStore.SaveAsync(userId, refreshToken);
        }

        // ✅ Lấy refresh token từ DB
        public async Task<RefreshToken?> GetRefreshTokenAsync(string token)
        {
            return await _refreshStore.GetByTokenAsync(token);
        }

        // ✅ Revoke refresh token (đánh dấu không dùng nữa)
        public async Task RevokeRefreshTokenAsync(Guid id)
        {
            await _refreshStore.RevokeAsync(id);
        }

        // ✅ Lấy thông tin user từ DB
        public async Task<User?> GetUserByIdAsync(string userId)
        {
            return await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);
        }
    }
}