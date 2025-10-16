using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace EducationManagement.Common.Models
{
    public class Subject
    {
        public string SubjectId { get; set; }
        public string SubjectCode { get; set; }     // Mã môn học (CS101, ENG101)
        public string SubjectName { get; set; }     // Tên môn học
        public int Credits { get; set; }            // Số tín chỉ
        public string? Description { get; set; }    // Mô tả chi tiết

        public string DepartmentId { get; set; }    // 🔗 FK tới Department

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
