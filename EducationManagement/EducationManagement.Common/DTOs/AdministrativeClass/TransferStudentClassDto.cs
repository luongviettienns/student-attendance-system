using System.ComponentModel.DataAnnotations;

namespace EducationManagement.Common.DTOs.AdministrativeClass
{
    /// <summary>
    /// DTO để chuyển sinh viên từ lớp này sang lớp khác
    /// </summary>
    public class TransferStudentClassDto
    {
        [Required(ErrorMessage = "Mã sinh viên là bắt buộc")]
        public string StudentId { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mã lớp đích là bắt buộc")]
        public string ToClassId { get; set; } = string.Empty;

        [MaxLength(500, ErrorMessage = "Lý do chuyển lớp không được vượt quá 500 ký tự")]
        public string? TransferReason { get; set; }
    }
}

