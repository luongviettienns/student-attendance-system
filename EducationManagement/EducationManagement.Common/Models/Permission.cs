using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("permissions")]
    public class Permission
    {
        [Key]
        [Column("permission_id")]
        public string PermissionId { get; set; } = Guid.NewGuid().ToString();

        [Column("permission_code")]
        [Required, MaxLength(100)]
        public string PermissionCode { get; set; }

        [Column("permission_name")]
        [Required, MaxLength(200)]
        public string PermissionName { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("is_active")]
        public bool IsActive { get; set; } = true;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

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
