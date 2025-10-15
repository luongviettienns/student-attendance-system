using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("RolePermissions")] // ⚙️ Đặt đúng tên bảng trong DB (PascalCase)
    public class RolePermission
    {
        [Key]
        [Column("RolePermissionId")]
        public string RolePermissionId { get; set; } = Guid.NewGuid().ToString();

        [Column("RoleId")]
        [Required]
        public string RoleId { get; set; }

        [Column("PermissionId")]
        [Required]
        public string PermissionId { get; set; }

        [Column("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("CreatedBy")]
        public string? CreatedBy { get; set; }

        [Column("DeletedAt")]
        public DateTime? DeletedAt { get; set; }

        [Column("DeletedBy")]
        public string? DeletedBy { get; set; }

        // 🔗 Navigation Properties
        [ForeignKey("RoleId")]
        public Role Role { get; set; }

        [ForeignKey("PermissionId")]
        public Permission Permission { get; set; }
    }
}
