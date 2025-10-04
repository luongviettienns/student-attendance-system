using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using EducationManagement.Common.Models;
using Microsoft.Extensions.Configuration;

namespace EducationManagement.BLL.Services
{
    public class JwtService
    {
        private readonly IConfiguration _config;

        public JwtService(IConfiguration config)
        {
            _config = config;
        }

        // 🔹 Sinh AccessToken ngắn hạn
        public string GenerateAccessToken(User user)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:SecretKey"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),        // UserId
                new Claim(ClaimTypes.Name, user.Username ?? string.Empty),           // Username
                new Claim("FullName", user.FullName ?? string.Empty),                // FullName
                new Claim(ClaimTypes.Role, user.Role?.RoleName ?? "User")            // Role
            };

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(
                    Convert.ToDouble(_config["Jwt:ExpireMinutes"] ?? "30")
                ),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        // 🔹 Sinh RefreshToken dài hạn
        public RefreshToken GenerateRefreshToken()
        {
            return new RefreshToken
            {
                Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
                ExpiresAt = DateTime.UtcNow.AddDays(7) // có thể config qua appsettings.json
            };
        }
    }
}
