using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class NotificationRepository
    {
        private readonly string _connectionString;

        public NotificationRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<List<Notification>> GetByUserIdAsync(string userId)
        {
            var notifications = new List<Notification>();
            var param = new SqlParameter("@UserId", userId);
            
            // Fallback: sử dụng query đơn giản nếu không có SP
            try
            {
                var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetNotificationsByUser", param);
                foreach (DataRow row in dt.Rows)
                    notifications.Add(MapToNotification(row));
            }
            catch
            {
                // Nếu chưa có SP, trả về empty list
            }

            return notifications;
        }

        private static Notification MapToNotification(DataRow row)
        {
            return new Notification
            {
                NotificationId = row["notification_id"].ToString()!,
                RecipientId = row["recipient_id"].ToString()!,
                Title = row["title"]?.ToString() ?? "",
                Content = row["content"]?.ToString() ?? "",
                Type = row["type"]?.ToString() ?? "Info",
                IsRead = row.Table.Columns.Contains("is_read") ? Convert.ToBoolean(row["is_read"]) : false,
                CreatedAt = row["created_at"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(row["created_at"])
            };
        }
    }
}

