using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("students")]
    public class Student
    {
        [Key]
        [Column("student_id")]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int StudentId { get; set; }

        [Required]
        [Column("username")]
        [MaxLength(50)]
        public string Username { get; set; }

        [Required]
        [Column("password_hash")]
        [MaxLength(255)]
        public string PasswordHash { get; set; }

        [Column("email")]
        [MaxLength(100)]
        public string Email { get; set; }

        [Column("phone")]
        [MaxLength(15)]
        public string? Phone { get; set; }

        [Required]
        [Column("full_name")]
        [MaxLength(100)]
        public string FullName { get; set; }

        [Column("gender")]
        [MaxLength(10)]
        public string? Gender { get; set; }

        [Column("dob")]
        public DateTime Dob { get; set; }

        [Column("faculty_id")]
        public int FacultyId { get; set; }

        [Column("major_id")]
        public int MajorId { get; set; }

        [Column("academic_year_id")]
        public int AcademicYearId { get; set; }

        [Column("cohort_year")]
        public int CohortYear { get; set; }

        [Column("nationality")]
        [MaxLength(50)]
        public string? Nationality { get; set; }

        [Column("ethnicity")]
        [MaxLength(50)]
        public string? Ethnicity { get; set; }

        [Column("religion")]
        [MaxLength(50)]
        public string? Religion { get; set; }

        [Column("hometown")]
        [MaxLength(255)]
        public string? Hometown { get; set; }

        [Column("current_address")]
        [MaxLength(255)]
        public string? CurrentAddress { get; set; }

        [Column("father_name")]
        [MaxLength(100)]
        public string? FatherName { get; set; }

        [Column("father_phone")]
        [MaxLength(15)]
        public string? FatherPhone { get; set; }

        [Column("father_job")]
        [MaxLength(100)]
        public string? FatherJob { get; set; }

        [Column("mother_name")]
        [MaxLength(100)]
        public string? MotherName { get; set; }

        [Column("mother_phone")]
        [MaxLength(15)]
        public string? MotherPhone { get; set; }

        [Column("mother_job")]
        [MaxLength(100)]
        public string? MotherJob { get; set; }

        [Column("created_by")]
        [MaxLength(50)]
        public string CreatedBy { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        [Column("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        [Column("updated_by")]
        public string? UpdatedBy { get; set; }

        [Column("deleted_at")]
        public DateTime? DeletedAt { get; set; }

        [Column("deleted_by")]
        public string? DeletedBy { get; set; }
    }
}
