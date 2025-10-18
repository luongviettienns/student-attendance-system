using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducationManagement.Common.DTOs.Student
{
    public class StudentCreateDTO
    {
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string FullName { get; set; }
        public string Gender { get; set; }
        public DateTime Dob { get; set; }
        public string FacultyId { get; set; }
        public string MajorId { get; set; }
        public string AcademicYearId { get; set; }
        public string CohortYear { get; set; }

        // Profile
        public string? Nationality { get; set; }
        public string? Ethnicity { get; set; }
        public string? Religion { get; set; }
        public string? Hometown { get; set; }
        public string? CurrentAddress { get; set; }

        // Family
        public string? FatherName { get; set; }
        public string? FatherPhone { get; set; }
        public string? FatherJob { get; set; }
        public string? MotherName { get; set; }
        public string? MotherPhone { get; set; }
        public string? MotherJob { get; set; }

        public string CreatedBy { get; set; } = "system";
    }
}
