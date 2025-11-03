using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("attendances")]
    public class Attendance
    {
        [Key]
        [Column("attendance_id")]
        public string AttendanceId { get; set; } = string.Empty;

        [Required]
        [Column("enrollment_id")]
        [MaxLength(50)]
        public string EnrollmentId { get; set; } = string.Empty;

        [Required]
        [Column("class_id")]
        [MaxLength(50)]
        public string ClassId { get; set; } = string.Empty;

        // 🔹 Map thông tin bổ sung từ các SP
        [NotMapped]
        public string? StudentId { get; set; }

        [NotMapped]
        public string? StudentCode { get; set; }

        [NotMapped]
        public string? StudentName { get; set; }

        [Required]
        [Column("attendance_date")]
        public DateTime AttendanceDate { get; set; } = DateTime.Now;

        [Required]
        [Column("status")]
        [MaxLength(20)]
        public string Status { get; set; } = "PRESENT"; // PRESENT, ABSENT, LATE, EXCUSED

        [Column("note")]
        [MaxLength(500)]
        public string? Note { get; set; }

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

        // 🔹 Thông tin bổ sung (map từ view / SP)
        [NotMapped]
        public string? ClassName { get; set; }

        [NotMapped]
        public string? SubjectName { get; set; }

        [NotMapped]
        public DateTime? ScheduleStartTime { get; set; }

        [NotMapped]
        public string? ScheduleId { get; set; }

        [NotMapped]
        public string? Room { get; set; }

        [NotMapped]
        public string? MarkedBy { get; set; }

        [NotMapped]
        public string? MarkedByName { get; set; }
    }
}
