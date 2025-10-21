using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;

namespace EducationManagement.BLL.Services
{
    /// <summary>
    /// Service gửi email thông báo
    /// </summary>
    public class EmailService
    {
        private readonly IConfiguration _configuration;
        private readonly string _smtpServer;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
            _smtpServer = configuration["Email:SmtpServer"] ?? "smtp.gmail.com";
            _smtpPort = int.Parse(configuration["Email:SmtpPort"] ?? "587");
            _smtpUsername = configuration["Email:Username"] ?? "";
            _smtpPassword = configuration["Email:Password"] ?? "";
            _fromEmail = configuration["Email:FromEmail"] ?? "noreply@edu.com";
            _fromName = configuration["Email:FromName"] ?? "Hệ thống Quản lý Giáo dục";
        }

        /// <summary>
        /// Gửi email đơn giản
        /// </summary>
        public async Task SendEmailAsync(string toEmail, string subject, string body, bool isHtml = true)
        {
            try
            {
                using var message = new MailMessage();
                message.From = new MailAddress(_fromEmail, _fromName);
                message.To.Add(new MailAddress(toEmail));
                message.Subject = subject;
                message.Body = body;
                message.IsBodyHtml = isHtml;

                using var client = new SmtpClient(_smtpServer, _smtpPort);
                client.EnableSsl = true;
                client.UseDefaultCredentials = false;
                client.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);

                await client.SendMailAsync(message);
            }
            catch (Exception ex)
            {
                // Log error (TODO: implement proper logging)
                Console.WriteLine($"❌ Lỗi gửi email: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Gửi email cho nhiều người nhận
        /// </summary>
        public async Task SendBulkEmailAsync(List<string> toEmails, string subject, string body, bool isHtml = true)
        {
            var tasks = toEmails.Select(email => SendEmailAsync(email, subject, body, isHtml));
            await Task.WhenAll(tasks);
        }

        /// <summary>
        /// Gửi email cảnh báo vắng học
        /// </summary>
        public async Task SendAttendanceWarningAsync(string studentEmail, string studentName, string className, double absentRate)
        {
            var subject = "⚠️ Cảnh báo vắng học";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #ff6b6b;'>Cảnh báo vắng học</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Chúng tôi nhận thấy bạn đã vắng mặt <strong>{absentRate:F1}%</strong> buổi học của lớp <strong>{className}</strong>.</p>
                    <p>Theo quy định, nếu vắng quá 20% số buổi học, bạn sẽ không được dự thi.</p>
                    <p>Vui lòng liên hệ với giảng viên hoặc phòng đào tạo nếu có lý do chính đáng.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Phòng Đào tạo</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email thông báo điểm
        /// </summary>
        public async Task SendGradeNotificationAsync(string studentEmail, string studentName, string className, double finalGrade)
        {
            var subject = "📊 Thông báo điểm";
            var status = finalGrade >= 4.0 ? "Đạt" : "Không đạt";
            var statusColor = finalGrade >= 4.0 ? "#4CAF50" : "#ff6b6b";
            
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #2196F3;'>Thông báo điểm</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Điểm môn học <strong>{className}</strong> của bạn đã được cập nhật:</p>
                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>
                        <p style='font-size: 18px; margin: 5px 0;'>
                            Điểm: <strong style='color: {statusColor};'>{finalGrade:F2}</strong>
                        </p>
                        <p style='font-size: 16px; margin: 5px 0;'>
                            Kết quả: <strong style='color: {statusColor};'>{status}</strong>
                        </p>
                    </div>
                    <p>Bạn có thể xem chi tiết trên hệ thống.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Phòng Đào tạo</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email reset mật khẩu
        /// </summary>
        public async Task SendPasswordResetAsync(string email, string resetToken, string resetUrl)
        {
            var subject = "🔐 Yêu cầu đặt lại mật khẩu";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #2196F3;'>Đặt lại mật khẩu</h2>
                    <p>Bạn đã yêu cầu đặt lại mật khẩu.</p>
                    <p>Nhấp vào liên kết bên dưới để đặt lại mật khẩu (có hiệu lực trong 30 phút):</p>
                    <p>
                        <a href='{resetUrl}?token={resetToken}' 
                           style='background-color: #2196F3; color: white; padding: 10px 20px; 
                                  text-decoration: none; border-radius: 5px; display: inline-block;'>
                            Đặt lại mật khẩu
                        </a>
                    </p>
                    <p>Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Hệ thống Quản lý Giáo dục</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(email, subject, body, true);
        }
    }
}

