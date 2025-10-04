using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducationManagement.Common.DTOs.User
{
    public class UserUpdateDto
    {
        public string FullName { get; set; }
        public string Email { get; set; }
        public string? Phone { get; set; }
    }

}
