using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("grades")]
    public class Grade
    {
        [Key]
        [Column("grade_id")]
        public string GradeId { get; set; } = string.Empty;

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

        [Required]
        [Column("grade_type")]
        [MaxLength(20)]
        public string GradeType { get; set; } = string.Empty; // Quiz, Midterm, Final, Assignment

        [Required]
        [Column("score")]
        [Range(0, 10, ErrorMessage = "Score must be between 0 and 10")]
        public decimal Score { get; set; }

        [Required]
        [Column("max_score")]
        [Range(0, 10, ErrorMessage = "Max score must be between 0 and 10")]
        public decimal MaxScore { get; set; } = 10.0m;

        [Required]
        [Column("weight")]
        [Range(0, 1, ErrorMessage = "Weight must be between 0 and 1")]
        public decimal Weight { get; set; } = 1.0m;

        [Column("notes")]
        [MaxLength(500)]
        public string? Notes { get; set; }

        [Column("graded_by")]
        [MaxLength(50)]
        public string? GradedBy { get; set; }

        // 🔹 Thêm để map kết quả SP (u.full_name)
        [NotMapped]
        public string? GradedByName { get; set; }

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
