using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("academic_years")]
    public class AcademicYear
    {
        [Key]
        [Column("academic_year_id")]
        public string AcademicYearId { get; set; }

        [Column("year_code")]
        public string YearCode { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("is_active")]
        public bool IsActive { get; set; } = true; // ⚙️ thêm mặc định cho rõ ràng

        // ================================
        // 🔹 Audit fields
        // ================================

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now; // ✅ thêm default để không null

        [Column("created_by")]
        public string? CreatedBy { get; set; }

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
