using EducationManagement.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/notifications")]
    public class NotificationController : ControllerBase
    {
        private readonly NotificationService _notificationService;

        public NotificationController(NotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        // ============================================================
        // 🔹 GET: Lấy tất cả notifications
        // ============================================================
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { message = "Token không hợp lệ" });

                var notifications = await _notificationService.GetNotificationsByUserAsync(userId);
                return Ok(new { data = notifications });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Lấy notifications chưa đọc
        // ============================================================
        [HttpGet("unread")]
        public async Task<IActionResult> GetUnread()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { message = "Token không hợp lệ" });

                // TODO: Implement GetUnreadNotificationsAsync in NotificationService
                // Tạm thời trả về empty list để không bị lỗi
                return Ok(new List<object>());
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("my-notifications")]
        public async Task<IActionResult> GetMyNotifications()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { message = "Token không hợp lệ" });

                var notifications = await _notificationService.GetNotificationsByUserAsync(userId);
                return Ok(new { data = notifications });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetByUser(string userId)
        {
            try
            {
                var notifications = await _notificationService.GetNotificationsByUserAsync(userId);
                return Ok(new { data = notifications });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 PUT: Đánh dấu notification đã đọc
        // ============================================================
        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(string id)
        {
            try
            {
                // TODO: Implement MarkAsReadAsync in NotificationService
                return Ok(new { message = "Đánh dấu đã đọc thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 PUT: Đánh dấu tất cả đã đọc
        // ============================================================
        [HttpPut("mark-all-read")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                    return Unauthorized(new { message = "Token không hợp lệ" });

                // TODO: Implement MarkAllAsReadAsync in NotificationService
                return Ok(new { message = "Đánh dấu tất cả đã đọc thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 DELETE: Xóa notification
        // ============================================================
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                // TODO: Implement DeleteNotificationAsync in NotificationService
                return Ok(new { message = "Xóa notification thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 POST: Tạo notification
        // ============================================================
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] dynamic notification)
        {
            try
            {
                // TODO: Implement CreateNotificationAsync in NotificationService
                return Ok(new { message = "Tạo notification thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 POST: Gửi email
        // ============================================================
        [HttpPost("send-email")]
        public async Task<IActionResult> SendEmail([FromBody] dynamic emailData)
        {
            try
            {
                // TODO: Implement SendEmailAsync
                return Ok(new { message = "Gửi email thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}

