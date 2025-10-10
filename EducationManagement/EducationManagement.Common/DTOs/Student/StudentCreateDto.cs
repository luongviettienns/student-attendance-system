using System.ComponentModel.DataAnnotations;

namespace EducationManagement.Common.DTOs.Student
{
    public class StudentCreateDto
    {
        [Required(ErrorMessage = "Tên đăng nhập là bắt buộc")]
        [StringLength(50, ErrorMessage = "Tên đăng nhập không được quá 50 ký tự")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Mật khẩu phải từ 6-100 ký tự")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mã sinh viên là bắt buộc")]
        [StringLength(20, ErrorMessage = "Mã sinh viên không được quá 20 ký tự")]
        public string StudentCode { get; set; } = string.Empty;

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

        public bool IsActive { get; set; } = true;
    }
}




