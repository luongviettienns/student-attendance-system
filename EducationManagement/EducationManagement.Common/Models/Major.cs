using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EducationManagement.Common.Models
{
    public class Major
    {
        public string MajorId { get; set; }
        public string MajorCode { get; set; }
        public string MajorName { get; set; }
        public string FacultyId { get; set; }   // 🔗 Liên kết đến Khoa
        public string? Description { get; set; }

        // Audit
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public string? CreatedBy { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string? UpdatedBy { get; set; }
        public DateTime? DeletedAt { get; set; }
        public string? DeletedBy { get; set; }
    }
}
