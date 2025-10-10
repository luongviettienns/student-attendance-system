using System.ComponentModel.DataAnnotations;

namespace EducationManagement.Common.DTOs.Student
{
    public class StudentUpdateDto
    {
        [Required(ErrorMessage = "Họ tên là bắt buộc")]
        [StringLength(150, ErrorMessage = "Họ tên không được quá 150 ký tự")]
        public string FullName { get; set; } = string.Empty;

        [StringLength(10, ErrorMessage = "Giới tính không được quá 10 ký tự")]
        public string? Gender { get; set; }

        public DateTime? Dob { get; set; }

        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        [StringLength(150, ErrorMessage = "Email không được quá 150 ký tự")]
        public string? Email { get; set; }

        [StringLength(20, ErrorMessage = "Số điện thoại không được quá 20 ký tự")]
        public string? Phone { get; set; }

        public string? FacultyId { get; set; }
        public string? MajorId { get; set; }
        public string? AcademicYearId { get; set; }

        [StringLength(10, ErrorMessage = "Năm nhập học không được quá 10 ký tự")]
        public string? CohortYear { get; set; }

        public bool IsActive { get; set; }
    }
}















