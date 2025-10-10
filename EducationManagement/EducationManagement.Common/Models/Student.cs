using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("students")]
    public class Student
    {
        [Key]
        [Column("student_id")]
        public string StudentId { get; set; } = string.Empty;

        [Required]
        [Column("user_id")]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [Column("student_code")]
        [StringLength(20)]
        public string StudentCode { get; set; } = string.Empty;

        [Required]
        [Column("full_name")]
        [StringLength(150)]
        public string FullName { get; set; } = string.Empty;

        [Column("gender")]
        [StringLength(10)]
        public string? Gender { get; set; }

        [Column("dob")]
        public DateTime? Dob { get; set; }

        [Column("email")]
        [StringLength(150)]
        public string? Email { get; set; }

        [Column("phone")]
        [StringLength(20)]
        public string? Phone { get; set; }

        [Column("faculty_id")]
        [StringLength(50)]
        public string? FacultyId { get; set; }

        [Column("major_id")]
        [StringLength(50)]
        public string? MajorId { get; set; }

        [Column("academic_year_id")]
        [StringLength(50)]
        public string? AcademicYearId { get; set; }

        [Column("cohort_year")]
        [StringLength(10)]
        public string? CohortYear { get; set; }

        [Column("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("created_by")]
        [StringLength(50)]
        public string? CreatedBy { get; set; }

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        [Column("updated_by")]
        [StringLength(50)]
        public string? UpdatedBy { get; set; }

        [Column("deleted_at")]
        public DateTime? DeletedAt { get; set; }

        [Column("deleted_by")]
        [StringLength(50)]
        public string? DeletedBy { get; set; }

        // Navigation properties
        public virtual User User { get; set; } = null!;
        public virtual ICollection<StudentProfile> StudentProfiles { get; set; } = new List<StudentProfile>();
        public virtual ICollection<StudentFamily> StudentFamilies { get; set; } = new List<StudentFamily>();
    }
}















