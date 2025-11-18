using System;

namespace EducationManagement.Common.DTOs.AdministrativeClass
{
    /// <summary>
    /// DTO để hiển thị lịch sử chuyển lớp
    /// </summary>
    public class ClassTransferHistoryDto
    {
        public string TransferId { get; set; } = string.Empty;
        public string StudentId { get; set; } = string.Empty;
        public string StudentCode { get; set; } = string.Empty;
        public string StudentName { get; set; } = string.Empty;
        
        public string? FromClassId { get; set; }
        public string? FromClassCode { get; set; }
        public string? FromClassName { get; set; }
        
        public string ToClassId { get; set; } = string.Empty;
        public string ToClassCode { get; set; } = string.Empty;
        public string ToClassName { get; set; } = string.Empty;
        
        public string? TransferReason { get; set; }
        public DateTime TransferDate { get; set; }
        
        public string TransferredBy { get; set; } = string.Empty;
        public string? TransferredByName { get; set; }
        
        public DateTime CreatedAt { get; set; }
    }
}

