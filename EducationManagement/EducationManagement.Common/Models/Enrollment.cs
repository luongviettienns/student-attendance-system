using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("enrollments")]
    public class Enrollment
    {
        [Key]
        [Column("enrollment_id")]
        public string EnrollmentId { get; set; } = string.Empty;

        [Required]
        [Column("student_id")]
        [MaxLength(50)]
        public string StudentId { get; set; } = string.Empty;

        // 🔹 Thêm để map kết quả SP (s.student_code, s.full_name)
        [NotMapped]
        public string? StudentCode { get; set; }

        [NotMapped]
        public string? StudentName { get; set; }

        [Required]
        [Column("class_id")]
        [MaxLength(50)]
        public string ClassId { get; set; } = string.Empty;

        // 🔹 Thêm để map kết quả SP (c.class_name, c.class_code)
        [NotMapped]
        public string? ClassName { get; set; }

        [NotMapped]
        public string? ClassCode { get; set; }

        [Column("enrollment_date")]
        public DateTime EnrollmentDate { get; set; } = DateTime.Now;

        [Required]
        [Column("status")]
        [MaxLength(20)]
        public string Status { get; set; } = "Active"; // Active, Dropped, Completed

        [Column("dropped_date")]
        public DateTime? DroppedDate { get; set; }

        [Column("dropped_reason")]
        [MaxLength(500)]
        public string? DroppedReason { get; set; }

        // ==================================================
        // 🔹 Audit fields
        // ==================================================
        [Column("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        public DateTime? CreatedAt { get; set; }

        [Column("created_by")]
        [MaxLength(50)]
        public string? CreatedBy { get; set; }

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        [Column("updated_by")]
        [MaxLength(50)]
        public string? UpdatedBy { get; set; }

        [Column("deleted_at")]
        public DateTime? DeletedAt { get; set; }

        [Column("deleted_by")]
        [MaxLength(50)]
        public string? DeletedBy { get; set; }
    }
}
