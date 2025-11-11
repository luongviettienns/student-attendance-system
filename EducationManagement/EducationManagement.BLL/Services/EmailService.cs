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

        /// <summary>
        /// Gửi email cảnh báo học tập (GPA thấp)
        /// </summary>
        public async Task SendAcademicWarningAsync(string studentEmail, string studentName, string className, decimal gpa, string? customSubject = null, string? customMessage = null)
        {
            var subject = customSubject ?? "⚠️ Cảnh báo học tập - GPA thấp";
            var body = customMessage ?? $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #ff6b6b;'>Cảnh báo học tập</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Chúng tôi nhận thấy GPA tích lũy của bạn hiện tại là <strong>{gpa:F2}</strong>, thấp hơn ngưỡng quy định (2.0).</p>
                    <p>Lớp: <strong>{className}</strong></p>
                    <p>Vui lòng liên hệ với cố vấn học tập hoặc phòng đào tạo để được hỗ trợ cải thiện kết quả học tập.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Phòng Đào tạo</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email cảnh báo chuyên cần (tỷ lệ vắng cao)
        /// </summary>
        public async Task SendAttendanceWarningEmailAsync(string studentEmail, string studentName, string className, decimal absenceRate, string? customSubject = null, string? customMessage = null)
        {
            var subject = customSubject ?? "⚠️ Cảnh báo chuyên cần - Tỷ lệ vắng cao";
            var body = customMessage ?? $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #ff6b6b;'>Cảnh báo chuyên cần</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Chúng tôi nhận thấy tỷ lệ vắng mặt của bạn là <strong>{absenceRate:F1}%</strong>, vượt quá ngưỡng quy định (20%).</p>
                    <p>Lớp: <strong>{className}</strong></p>
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
        /// Gửi email cảnh báo cả hai (GPA thấp + vắng cao)
        /// </summary>
        public async Task SendBothWarningEmailAsync(string studentEmail, string studentName, string className, decimal gpa, decimal absenceRate, string? customSubject = null, string? customMessage = null)
        {
            var subject = customSubject ?? "⚠️ Cảnh báo: GPA thấp và Tỷ lệ vắng cao";
            var body = customMessage ?? $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #ff6b6b;'>Cảnh báo học tập và chuyên cần</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Chúng tôi nhận thấy bạn đang gặp vấn đề về cả học tập và chuyên cần:</p>
                    <ul>
                        <li><strong>GPA tích lũy:</strong> {gpa:F2} (thấp hơn ngưỡng quy định 2.0)</li>
                        <li><strong>Tỷ lệ vắng mặt:</strong> {absenceRate:F1}% (vượt quá ngưỡng quy định 20%)</li>
                    </ul>
                    <p>Lớp: <strong>{className}</strong></p>
                    <p>Vui lòng liên hệ ngay với cố vấn học tập hoặc phòng đào tạo để được hỗ trợ kịp thời.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Phòng Đào tạo</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email thông báo có phúc khảo mới (cho Advisor)
        /// </summary>
        public async Task SendGradeAppealCreatedEmailAsync(string advisorEmail, string advisorName, string studentName, string subjectName, string appealId, string appealReason)
        {
            var subject = "📋 Yêu cầu phúc khảo mới";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #2196F3;'>Yêu cầu phúc khảo mới</h2>
                    <p>Kính gửi <strong>{advisorName}</strong>,</p>
                    <p>Sinh viên <strong>{studentName}</strong> đã tạo yêu cầu phúc khảo điểm cho môn học <strong>{subjectName}</strong>.</p>
                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>
                        <p><strong>Mã yêu cầu:</strong> {appealId}</p>
                        <p><strong>Lý do phúc khảo:</strong></p>
                        <p style='margin-left: 20px;'>{appealReason}</p>
                    </div>
                    <p>Vui lòng đăng nhập vào hệ thống để xem chi tiết và xử lý yêu cầu phúc khảo.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Hệ thống Quản lý Giáo dục</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(advisorEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email thông báo phản hồi từ giảng viên (cho Student)
        /// </summary>
        public async Task SendGradeAppealLecturerResponseEmailAsync(string studentEmail, string studentName, string lecturerName, string subjectName, string decision, string? response)
        {
            var decisionText = decision switch
            {
                "APPROVE" => "đồng ý",
                "REJECT" => "từ chối",
                "NEED_REVIEW" => "yêu cầu xem xét thêm",
                _ => decision
            };

            var decisionColor = decision switch
            {
                "APPROVE" => "#4CAF50",
                "REJECT" => "#ff6b6b",
                "NEED_REVIEW" => "#FF9800",
                _ => "#2196F3"
            };

            var subject = "📨 Phản hồi từ giảng viên về phúc khảo";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #2196F3;'>Phản hồi từ giảng viên</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Giảng viên <strong>{lecturerName}</strong> đã phản hồi yêu cầu phúc khảo của bạn cho môn học <strong>{subjectName}</strong>.</p>
                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>
                        <p style='font-size: 16px; margin: 5px 0;'>
                            Quyết định: <strong style='color: {decisionColor};'>{decisionText}</strong>
                        </p>
                        {(string.IsNullOrEmpty(response) ? "" : $@"
                        <p><strong>Phản hồi:</strong></p>
                        <p style='margin-left: 20px;'>{response}</p>
                        ")}
                    </div>
                    {(decision == "NEED_REVIEW" ? "<p>Yêu cầu phúc khảo của bạn đã được chuyển đến cố vấn học tập để xem xét và quyết định cuối cùng.</p>" : "")}
                    <p>Bạn có thể xem chi tiết trên hệ thống.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Hệ thống Quản lý Giáo dục</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email thông báo quyết định từ cố vấn (cho Student)
        /// </summary>
        public async Task SendGradeAppealAdvisorDecisionEmailAsync(string studentEmail, string studentName, string advisorName, string subjectName, string decision, decimal? finalScore, string? response)
        {
            var decisionText = decision == "APPROVE" ? "đồng ý" : "từ chối";
            var decisionColor = decision == "APPROVE" ? "#4CAF50" : "#ff6b6b";

            var subject = decision == "APPROVE" ? "✅ Phúc khảo đã được duyệt" : "❌ Phúc khảo đã bị từ chối";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: {decisionColor};'>Quyết định phúc khảo</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Cố vấn học tập <strong>{advisorName}</strong> đã quyết định <strong style='color: {decisionColor};'>{decisionText}</strong> yêu cầu phúc khảo của bạn cho môn học <strong>{subjectName}</strong>.</p>
                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>
                        {(finalScore.HasValue ? $@"
                        <p style='font-size: 18px; margin: 5px 0;'>
                            Điểm sau phúc khảo: <strong style='color: {decisionColor};'>{finalScore.Value:F2}</strong>
                        </p>
                        " : "")}
                        {(string.IsNullOrEmpty(response) ? "" : $@"
                        <p><strong>Phản hồi:</strong></p>
                        <p style='margin-left: 20px;'>{response}</p>
                        ")}
                    </div>
                    <p>Bạn có thể xem chi tiết trên hệ thống.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Hệ thống Quản lý Giáo dục</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }

        /// <summary>
        /// Gửi email thông báo đăng ký học phần đã được duyệt
        /// </summary>
        public async Task SendEnrollmentApprovedEmailAsync(string studentEmail, string studentName, string className, string subjectName, DateTime enrollmentDate)
        {
            var subject = "✅ Đăng ký học phần đã được duyệt";
            var body = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #4CAF50;'>Đăng ký học phần thành công</h2>
                    <p>Kính gửi <strong>{studentName}</strong>,</p>
                    <p>Đăng ký học phần của bạn đã được duyệt:</p>
                    <div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>
                        <p><strong>Lớp học:</strong> {className}</p>
                        <p><strong>Môn học:</strong> {subjectName}</p>
                        <p><strong>Ngày đăng ký:</strong> {enrollmentDate:dd/MM/yyyy HH:mm}</p>
                    </div>
                    <p>Bạn có thể xem lịch học và thông tin lớp học trên hệ thống.</p>
                    <br/>
                    <p>Trân trọng,</p>
                    <p><strong>Phòng Đào tạo</strong></p>
                </body>
                </html>
            ";

            await SendEmailAsync(studentEmail, subject, body, true);
        }
    }
}

