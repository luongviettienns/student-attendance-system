using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class AuditLogService
    {
        private readonly AuditLogRepository _auditLogRepository;

        public AuditLogService(AuditLogRepository auditLogRepository)
        {
            _auditLogRepository = auditLogRepository;
        }

        public async Task<(List<AuditLogDto> Logs, int TotalCount)> GetAllAuditLogsAsync(
            int page = 1,
            int pageSize = 10,
            string? search = null,
            string? action = null,
            DateTime? fromDate = null,
            DateTime? toDate = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 100) pageSize = 100;

            return await _auditLogRepository.GetAllAsync(page, pageSize, search, action, fromDate, toDate);
        }
    }
}

