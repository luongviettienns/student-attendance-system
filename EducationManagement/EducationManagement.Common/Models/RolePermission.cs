using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace EducationManagement.Common.Models
{
    [Table("role_permissions")]
    public class RolePermission
    {
        [Column("role_id")]
        public string RoleId { get; set; }

        [Column("permission_id")]
        public string PermissionId { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("created_by")]
        public string? CreatedBy { get; set; }

        [Column("deleted_at")]
        public DateTime? DeletedAt { get; set; }

        [Column("deleted_by")]
        public string? DeletedBy { get; set; }

        // 🔗 Navigation Properties
        public Role Role { get; set; }
        public Permission Permission { get; set; }
    }
}
