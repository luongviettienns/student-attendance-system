using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;

namespace EducationManagement.API.Admin.Controllers
{
    /// <summary>
    /// Controller gửi email thông báo
    /// </summary>
    [ApiController]
    [Authorize]
    [Route("api-edu/email")]
    public class EmailController : ControllerBase
    {
        private readonly EmailService _emailService;

        public EmailController(EmailService emailService)
        {
            _emailService = emailService;
        }

        /// <summary>
        /// Gửi email đơn giản
        /// </summary>
        [HttpPost("send")]
        public async Task<IActionResult> SendEmail([FromBody] EmailRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.ToEmail) || 
                string.IsNullOrWhiteSpace(request.Subject) || 
                string.IsNullOrWhiteSpace(request.Body))
            {
                return BadRequest(new { message = "Thiếu thông tin email" });
            }

            try
            {
                await _emailService.SendEmailAsync(request.ToEmail, request.Subject, request.Body, request.IsHtml);
                return Ok(new { message = "Email đã được gửi thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi gửi email", error = ex.Message });
            }
        }

        /// <summary>
        /// Gửi email cho nhiều người
        /// </summary>
        [HttpPost("send-bulk")]
        public async Task<IActionResult> SendBulkEmail([FromBody] BulkEmailRequest request)
        {
            if (request.ToEmails == null || !request.ToEmails.Any() || 
                string.IsNullOrWhiteSpace(request.Subject) || 
                string.IsNullOrWhiteSpace(request.Body))
            {
                return BadRequest(new { message = "Thiếu thông tin email" });
            }

            try
            {
                await _emailService.SendBulkEmailAsync(request.ToEmails, request.Subject, request.Body, request.IsHtml);
                return Ok(new { message = $"Đã gửi email đến {request.ToEmails.Count} người nhận" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi gửi email", error = ex.Message });
            }
        }

        /// <summary>
        /// Gửi cảnh báo vắng học
        /// </summary>
        [HttpPost("attendance-warning")]
        [Authorize(Roles = "Admin,Lecturer")]
        public async Task<IActionResult> SendAttendanceWarning([FromBody] AttendanceWarningRequest request)
        {
            try
            {
                await _emailService.SendAttendanceWarningAsync(
                    request.StudentEmail, 
                    request.StudentName, 
                    request.ClassName, 
                    request.AbsentRate);
                
                return Ok(new { message = "Đã gửi email cảnh báo vắng học" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi gửi email", error = ex.Message });
            }
        }

        /// <summary>
        /// Gửi thông báo điểm
        /// </summary>
        [HttpPost("grade-notification")]
        [Authorize(Roles = "Admin,Lecturer")]
        public async Task<IActionResult> SendGradeNotification([FromBody] GradeNotificationRequest request)
        {
            try
            {
                await _emailService.SendGradeNotificationAsync(
                    request.StudentEmail, 
                    request.StudentName, 
                    request.ClassName, 
                    request.FinalGrade);
                
                return Ok(new { message = "Đã gửi email thông báo điểm" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi gửi email", error = ex.Message });
            }
        }

        // ===========================================
        // TEST ENDPOINTS - Để test email templates
        // ===========================================

        /// <summary>
        /// Preview email template (trả về HTML để xem trong browser)
        /// </summary>
        [HttpGet("preview/{templateType}")]
        [AllowAnonymous] // Cho phép test không cần đăng nhập
        public IActionResult PreviewEmailTemplate(string templateType)
        {
            var testData = new
            {
                StudentEmail = "test@example.com",
                StudentName = "Nguyễn Văn Test",
                ClassName = "Lập trình C# - Lớp 01",
                SubjectName = "Lập trình C#",
                AbsentRate = 25.5,
                FinalGrade = 8.5,
                GPA = 3.2m,
                SchoolYear = "2024-2025",
                Semester = 1,
                PeriodName = "Đợt đăng ký HK1 2024-2025",
                StartDate = DateTime.Now.AddDays(1),
                EndDate = DateTime.Now.AddDays(14),
                OTP = "123456",
                AppealId = "APL001",
                AppealReason = "Nghi ngờ có lỗi trong quá trình chấm điểm",
                LecturerName = "Trần Thị Hoa",
                AdvisorName = "Nguyễn Văn Cố Vấn",
                Decision = "APPROVE",
                FinalScore = 8.8m,
                EnrollmentDate = DateTime.Now
            };

            string html = templateType.ToLower() switch
            {
                "attendance-warning" => _emailService.PreviewAttendanceWarning(
                    testData.StudentName, testData.ClassName, testData.AbsentRate),
                
                "grade-notification" => _emailService.PreviewGradeNotification(
                    testData.StudentName, testData.ClassName, testData.FinalGrade),
                
                "enrollment-approved" => _emailService.PreviewEnrollmentApproved(
                    testData.StudentName, testData.ClassName, testData.SubjectName, testData.EnrollmentDate),
                
                "otp" => _emailService.PreviewOTP(
                    testData.StudentName, testData.OTP),
                
                _ => $@"
                    <html>
                    <body style='font-family: Arial, sans-serif; padding: 20px;'>
                        <h1>Template '{templateType}' chưa có preview</h1>
                        <p>Vui lòng sử dụng endpoint test để gửi email thực tế:</p>
                        <p><strong>POST /api-edu/email/test/{templateType}</strong></p>
                        <p>Các template có preview: attendance-warning, grade-notification, enrollment-approved, otp</p>
                        <p>Các template khác: enrollment-rejected, registration-period-open, registration-deadline-reminder, timetable-notification, gpa-notification, retake-notification, grade-appeal-created, grade-appeal-lecturer-response, grade-appeal-advisor-decision, academic-warning, both-warning</p>
                    </body>
                    </html>
                "
            };

            return Content(html, "text/html; charset=utf-8");
        }

        /// <summary>
        /// Test gửi email thực tế (gửi đến email của bạn)
        /// </summary>
        [HttpPost("test/{templateType}")]
        [AllowAnonymous] // Cho phép test không cần đăng nhập
        public async Task<IActionResult> TestSendEmail(string templateType, [FromBody] TestEmailRequest? request = null)
        {
            var testEmail = request?.ToEmail ?? "your-email@example.com"; // Thay bằng email của bạn
            
            if (string.IsNullOrWhiteSpace(testEmail) || !testEmail.Contains("@"))
            {
                return BadRequest(new { message = "Vui lòng cung cấp email hợp lệ trong body: { \"toEmail\": \"your-email@example.com\" }" });
            }

            var testData = new
            {
                StudentEmail = testEmail,
                StudentName = request?.StudentName ?? "Nguyễn Văn Test",
                ClassName = request?.ClassName ?? "Lập trình C# - Lớp 01",
                SubjectName = request?.SubjectName ?? "Lập trình C#",
                AbsentRate = request?.AbsentRate ?? 25.5,
                FinalGrade = request?.FinalGrade ?? 8.5,
                GPA = request?.GPA ?? 3.2m,
                SchoolYear = request?.SchoolYear ?? "2024-2025",
                Semester = request?.Semester ?? 1,
                PeriodName = request?.PeriodName ?? "Đợt đăng ký HK1 2024-2025",
                StartDate = request?.StartDate ?? DateTime.Now.AddDays(1),
                EndDate = request?.EndDate ?? DateTime.Now.AddDays(14),
                OTP = request?.OTP ?? "123456",
                AppealId = request?.AppealId ?? "APL001",
                AppealReason = request?.AppealReason ?? "Nghi ngờ có lỗi trong quá trình chấm điểm",
                LecturerName = request?.LecturerName ?? "Trần Thị Hoa",
                AdvisorName = request?.AdvisorName ?? "Nguyễn Văn Cố Vấn",
                Decision = request?.Decision ?? "APPROVE",
                FinalScore = request?.FinalScore ?? 8.8m,
                EnrollmentDate = request?.EnrollmentDate ?? DateTime.Now,
                Reason = request?.Reason ?? "Lớp đã đầy",
                Status = request?.Status ?? "APPROVED",
                AdvisorNotes = request?.AdvisorNotes ?? "Đã được duyệt học lại"
            };

            try
            {
                switch (templateType.ToLower())
                {
                    case "attendance-warning":
                        await _emailService.SendAttendanceWarningAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.AbsentRate);
                        break;
                    
                    case "grade-notification":
                        await _emailService.SendGradeNotificationAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.FinalGrade);
                        break;
                    
                    case "enrollment-approved":
                        await _emailService.SendEnrollmentApprovedEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.SubjectName, testData.EnrollmentDate);
                        break;
                    
                    case "enrollment-rejected":
                        await _emailService.SendEnrollmentRejectedEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.SubjectName, testData.Reason);
                        break;
                    
                    case "registration-period-open":
                        await _emailService.SendRegistrationPeriodOpenEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.PeriodName, testData.StartDate, testData.EndDate);
                        break;
                    
                    case "registration-deadline-reminder":
                        await _emailService.SendRegistrationDeadlineReminderEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.PeriodName, testData.EndDate);
                        break;
                    
                    case "timetable-notification":
                        await _emailService.SendTimetableNotificationEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.SchoolYear, testData.Semester);
                        break;
                    
                    case "gpa-notification":
                        await _emailService.SendGPANotificationEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.SchoolYear, testData.Semester, 
                            testData.GPA * 2.5m, testData.GPA, "Khá", 15);
                        break;
                    
                    case "retake-notification":
                        await _emailService.SendRetakeNotificationEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.SubjectName, testData.ClassName, 
                            "ATTENDANCE", testData.Status, testData.AdvisorNotes);
                        break;
                    
                    case "otp":
                        await _emailService.SendOTPEmailAsync(
                            testData.StudentEmail, testData.OTP, testData.StudentName);
                        break;
                    
                    case "grade-appeal-created":
                        await _emailService.SendGradeAppealCreatedEmailAsync(
                            testEmail, testData.AdvisorName, testData.StudentName, testData.SubjectName, 
                            testData.AppealId, testData.AppealReason);
                        break;
                    
                    case "grade-appeal-lecturer-response":
                        await _emailService.SendGradeAppealLecturerResponseEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.LecturerName, testData.SubjectName, 
                            testData.Decision, "Đã kiểm tra lại, đồng ý điều chỉnh điểm");
                        break;
                    
                    case "grade-appeal-advisor-decision":
                        await _emailService.SendGradeAppealAdvisorDecisionEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.AdvisorName, testData.SubjectName, 
                            testData.Decision, testData.FinalScore, "Đã xác minh và đồng ý điều chỉnh");
                        break;
                    
                    case "academic-warning":
                        await _emailService.SendAcademicWarningAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.GPA);
                        break;
                    
                    case "both-warning":
                        await _emailService.SendBothWarningEmailAsync(
                            testData.StudentEmail, testData.StudentName, testData.ClassName, testData.GPA, (decimal)testData.AbsentRate);
                        break;
                    
                    default:
                        throw new ArgumentException($"Template '{templateType}' không tồn tại");
                }

                return Ok(new { 
                    message = $"Đã gửi email test '{templateType}' thành công đến {testEmail}",
                    templateType = templateType,
                    sentTo = testEmail
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi gửi email test", error = ex.Message, stackTrace = ex.StackTrace });
            }
        }

        /// <summary>
        /// Lấy danh sách tất cả email templates có sẵn
        /// </summary>
        [HttpGet("templates")]
        [AllowAnonymous]
        public IActionResult GetAvailableTemplates()
        {
            var templates = new[]
            {
                new { name = "attendance-warning", description = "Cảnh báo vắng học", previewUrl = "/api-edu/email/preview/attendance-warning" },
                new { name = "grade-notification", description = "Thông báo điểm môn học", previewUrl = "/api-edu/email/preview/grade-notification" },
                new { name = "enrollment-approved", description = "Đăng ký học phần được duyệt", previewUrl = "/api-edu/email/preview/enrollment-approved" },
                new { name = "enrollment-rejected", description = "Đăng ký học phần bị từ chối", previewUrl = "/api-edu/email/preview/enrollment-rejected" },
                new { name = "registration-period-open", description = "Đợt đăng ký học phần mở", previewUrl = "/api-edu/email/preview/registration-period-open" },
                new { name = "registration-deadline-reminder", description = "Nhắc nhở deadline đăng ký", previewUrl = "/api-edu/email/preview/registration-deadline-reminder" },
                new { name = "timetable-notification", description = "Thông báo lịch học mới", previewUrl = "/api-edu/email/preview/timetable-notification" },
                new { name = "gpa-notification", description = "Thông báo GPA học kỳ", previewUrl = "/api-edu/email/preview/gpa-notification" },
                new { name = "retake-notification", description = "Thông báo học lại", previewUrl = "/api-edu/email/preview/retake-notification" },
                new { name = "otp", description = "Mã OTP đặt lại mật khẩu", previewUrl = "/api-edu/email/preview/otp" },
                new { name = "grade-appeal-created", description = "Yêu cầu phúc khảo mới (cho Advisor)", previewUrl = "/api-edu/email/preview/grade-appeal-created" },
                new { name = "grade-appeal-lecturer-response", description = "Phản hồi từ giảng viên về phúc khảo", previewUrl = "/api-edu/email/preview/grade-appeal-lecturer-response" },
                new { name = "grade-appeal-advisor-decision", description = "Quyết định từ cố vấn về phúc khảo", previewUrl = "/api-edu/email/preview/grade-appeal-advisor-decision" },
                new { name = "academic-warning", description = "Cảnh báo học tập (GPA thấp)", previewUrl = "/api-edu/email/preview/academic-warning" },
                new { name = "both-warning", description = "Cảnh báo nghiêm trọng (GPA thấp + vắng cao)", previewUrl = "/api-edu/email/preview/both-warning" }
            };

            return Ok(new { 
                message = "Danh sách email templates",
                templates = templates,
                usage = new
                {
                    preview = "GET /api-edu/email/preview/{templateType} - Xem preview HTML trong browser",
                    test = "POST /api-edu/email/test/{templateType} - Gửi email test thực tế",
                    bodyExample = new { toEmail = "your-email@example.com", studentName = "Tên sinh viên", className = "Lớp học", finalGrade = 8.5 }
                }
            });
        }

    }

    // DTOs for Email requests
    public class EmailRequest
    {
        public string ToEmail { get; set; } = "";
        public string Subject { get; set; } = "";
        public string Body { get; set; } = "";
        public bool IsHtml { get; set; } = true;
    }

    public class BulkEmailRequest
    {
        public List<string> ToEmails { get; set; } = new();
        public string Subject { get; set; } = "";
        public string Body { get; set; } = "";
        public bool IsHtml { get; set; } = true;
    }

    public class AttendanceWarningRequest
    {
        public string StudentEmail { get; set; } = "";
        public string StudentName { get; set; } = "";
        public string ClassName { get; set; } = "";
        public double AbsentRate { get; set; }
    }

    public class GradeNotificationRequest
    {
        public string StudentEmail { get; set; } = "";
        public string StudentName { get; set; } = "";
        public string ClassName { get; set; } = "";
        public double FinalGrade { get; set; }
    }

    public class TestEmailRequest
    {
        public string ToEmail { get; set; } = "";
        public string? StudentName { get; set; }
        public string? ClassName { get; set; }
        public string? SubjectName { get; set; }
        public double? AbsentRate { get; set; }
        public double? FinalGrade { get; set; }
        public decimal? GPA { get; set; }
        public string? SchoolYear { get; set; }
        public int? Semester { get; set; }
        public string? PeriodName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? OTP { get; set; }
        public string? AppealId { get; set; }
        public string? AppealReason { get; set; }
        public string? LecturerName { get; set; }
        public string? AdvisorName { get; set; }
        public string? Decision { get; set; }
        public decimal? FinalScore { get; set; }
        public DateTime? EnrollmentDate { get; set; }
        public string? Reason { get; set; }
        public string? Status { get; set; }
        public string? AdvisorNotes { get; set; }
    }
}

