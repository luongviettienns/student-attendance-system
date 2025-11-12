using EducationManagement.BLL.Services;
using EducationManagement.DAL.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;

namespace EducationManagement.API.Admin.Controllers
{
    /// <summary>
    /// Base controller with audit logging helper methods
    /// </summary>
    public class BaseController : ControllerBase
    {
        protected readonly AuditLogService? _auditLogService;

        public BaseController(AuditLogService? auditLogService = null)
        {
            _auditLogService = auditLogService;
        }

        /// <summary>
        /// Get current user ID from JWT token
        /// </summary>
        protected string? GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        /// <summary>
        /// Create audit log entry
        /// </summary>
        protected async Task LogAuditAsync(
            string action,
            string entityType,
            string? entityId = null,
            object? oldValues = null,
            object? newValues = null)
        {
            if (_auditLogService == null) return;

            try
            {
                await _auditLogService.CreateAuditLogAsync(new AuditLogDto
                {
                    UserId = GetCurrentUserId(),
                    Action = action,
                    EntityType = entityType,
                    EntityId = entityId,
                    OldValues = oldValues != null ? JsonSerializer.Serialize(oldValues) : null,
                    NewValues = newValues != null ? JsonSerializer.Serialize(newValues) : null,
                    IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
                    UserAgent = HttpContext.Request.Headers["User-Agent"].ToString()
                });
            }
            catch
            {
                // Don't fail the request if audit logging fails
                // Log error silently (could add logger here if needed)
            }
        }

        /// <summary>
        /// Shortcut for CREATE action
        /// </summary>
        protected Task LogCreateAsync(string entityType, string? entityId, object? data)
            => LogAuditAsync("CREATE", entityType, entityId, null, data);

        /// <summary>
        /// Shortcut for UPDATE action
        /// </summary>
        protected Task LogUpdateAsync(string entityType, string? entityId, object? oldData, object? newData)
            => LogAuditAsync("UPDATE", entityType, entityId, oldData, newData);

        /// <summary>
        /// Shortcut for DELETE action
        /// </summary>
        protected Task LogDeleteAsync(string entityType, string? entityId, object? data)
            => LogAuditAsync("DELETE", entityType, entityId, data, null);

        /// <summary>
        /// Shortcut for LOGIN action
        /// </summary>
        protected Task LogLoginAsync(string userId, object? data)
            => LogAuditAsync("LOGIN", "Auth", userId, null, data);

        /// <summary>
        /// Shortcut for LOGOUT action
        /// </summary>
        protected Task LogLogoutAsync(string userId)
            => LogAuditAsync("LOGOUT", "Auth", userId, null, null);
    }
}

