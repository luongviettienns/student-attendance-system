using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace EducationManagement.DAL.Repositories
{
    public class AuditLogRepository
    {
        private readonly string _connectionString;

        public AuditLogRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<(List<AuditLogDto> Logs, int TotalCount)> GetAllAsync(
            int page = 1,
            int pageSize = 10,
            string? search = null,
            string? action = null,
            DateTime? fromDate = null,
            DateTime? toDate = null)
        {
            var logs = new List<AuditLogDto>();
            int totalCount = 0;

            // Placeholder implementation - sẽ cần SP thực tế
            // Trả về empty list cho giờ
            return (logs, totalCount);
        }
    }

    public class AuditLogDto
    {
        public string LogId { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string Action { get; set; } = string.Empty;
        public string? TableName { get; set; }
        public string? RecordId { get; set; }
        public string? OldValues { get; set; }
        public string? NewValues { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}

