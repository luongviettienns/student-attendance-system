using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducationManagement.Common.DTOs
{
    public class LoginResponse
    {
        public string Token { get; set; }
        public string RefreshToken { get; set; }
        public DateTime RefreshTokenExpiry { get; set; }

        public string UserId { get; set; }     // 👈 thêm
        public string Username { get; set; }
        public string Role { get; set; }
        public string FullName { get; set; }
        public string AvatarUrl { get; set; }  // 👈 thêm
    }
}
