using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace EducationManagement.BLL.Services
{
    /// <summary>
    /// Service quản lý email templates
    /// </summary>
    public class EmailTemplateService
    {
        private readonly string _templatesPath;

        public EmailTemplateService(string? basePath = null)
        {
            // Tìm thư mục EmailTemplates
            var templatesBasePath = basePath ?? Directory.GetCurrentDirectory();
            _templatesPath = Path.Combine(templatesBasePath, "EmailTemplates");
            
            // Tạo thư mục nếu chưa tồn tại
            if (!Directory.Exists(_templatesPath))
            {
                try
                {
                    Directory.CreateDirectory(_templatesPath);
                }
                catch
                {
                    // Ignore if cannot create directory
                }
            }
        }

        /// <summary>
        /// Lấy base email template với responsive design
        /// </summary>
        public string GetBaseTemplate(string title, string greeting, string content, string icon = "📧", string iconColor = "#3b82f6")
        {
            var currentYear = DateTime.Now.Year;
            var companyName = "Hệ thống Quản lý Giáo dục";
            var companyWebsite = "#"; // Có thể thêm website thực tế
            
            return $@"<!DOCTYPE html>
<html lang='vi'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <meta name='x-apple-disable-message-reformatting'>
    <title>{title}</title>
    <!--[if mso]>
    <noscript>
        <xml>
            <o:OfficeDocumentSettings>
                <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
        </xml>
    </noscript>
    <![endif]-->
    <style>
        /* Reset styles */
        body, table, td, p, a, li, blockquote {{
            -webkit-text-size-adjust: 100%;
            -ms-text-size-adjust: 100%;
        }}
        table, td {{
            mso-table-lspace: 0pt;
            mso-table-rspace: 0pt;
        }}
        img {{
            -ms-interpolation-mode: bicubic;
            border: 0;
            height: auto;
            line-height: 100%;
            outline: none;
            text-decoration: none;
        }}
        
        /* Mobile styles */
        @media only screen and (max-width: 600px) {{
            .email-container {{
                width: 100% !important;
                max-width: 100% !important;
            }}
            .email-content {{
                padding: 20px !important;
            }}
            .email-header {{
                padding: 24px 20px !important;
            }}
            .email-footer {{
                padding: 24px 20px !important;
            }}
            h1 {{
                font-size: 20px !important;
            }}
            .icon-large {{
                font-size: 36px !important;
            }}
        }}
    </style>
</head>
<body style='margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, ''Helvetica Neue'', Arial, sans-serif; background-color: #f1f5f9; line-height: 1.6; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;'>
    <!-- Preheader text -->
    <div style='display: none; font-size: 1px; color: #fefefe; line-height: 1px; font-family: sans-serif; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;'>
        {title}
    </div>
    
    <table role='presentation' style='width: 100%; border-collapse: collapse; background-color: #f1f5f9; padding: 20px 0;'>
        <tr>
            <td align='center' style='padding: 20px 0;'>
                <table role='presentation' class='email-container' style='width: 100%; max-width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);'>
                    <!-- Header -->
                    <tr>
                        <td class='email-header' style='background: linear-gradient(135deg, {iconColor} 0%, {GetDarkerColor(iconColor)} 100%); padding: 40px; text-align: center;'>
                            <div class='icon-large' style='font-size: 48px; margin-bottom: 16px; line-height: 1;'>{icon}</div>
                            <h1 style='margin: 0; color: #ffffff; font-size: 24px; font-weight: 700; letter-spacing: -0.5px; line-height: 1.2;'>{title}</h1>
                        </td>
                    </tr>
                    
                    <!-- Body -->
                    <tr>
                        <td class='email-content' style='padding: 40px; background-color: #ffffff;'>
                            <p style='margin: 0 0 24px 0; font-size: 16px; color: #334155; line-height: 1.6;'>
                                {greeting}
                            </p>
                            
                            {content}
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td class='email-footer' style='background-color: #f8fafc; padding: 32px 40px; border-top: 1px solid #e2e8f0;'>
                            <table role='presentation' style='width: 100%; border-collapse: collapse;'>
                                <tr>
                                    <td style='text-align: center; padding-bottom: 20px;'>
                                        <p style='margin: 0; font-size: 16px; color: #1e293b; font-weight: 600; margin-bottom: 8px;'>
                                            {companyName}
                                        </p>
                                        <p style='margin: 0; font-size: 14px; color: #64748b; line-height: 1.6;'>
                                            Email này được gửi tự động từ hệ thống.<br>
                                            Vui lòng không trả lời email này.
                                        </p>
                                    </td>
                                </tr>
                                <tr>
                                    <td style='text-align: center; padding-top: 20px; border-top: 1px solid #e2e8f0;'>
                                        <p style='margin: 0; font-size: 12px; color: #94a3b8;'>
                                            © {currentYear} {companyName}. Tất cả quyền được bảo lưu.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }

        /// <summary>
        /// Tạo màu tối hơn từ màu hex
        /// </summary>
        private string GetDarkerColor(string hexColor)
        {
            // Đơn giản hóa: giảm độ sáng 20%
            if (hexColor.StartsWith("#"))
            {
                hexColor = hexColor.Substring(1);
            }
            
            // Parse RGB
            var r = Convert.ToInt32(hexColor.Substring(0, 2), 16);
            var g = Convert.ToInt32(hexColor.Substring(2, 2), 16);
            var b = Convert.ToInt32(hexColor.Substring(4, 2), 16);
            
            // Darken by 20%
            r = Math.Max(0, (int)(r * 0.8));
            g = Math.Max(0, (int)(g * 0.8));
            b = Math.Max(0, (int)(b * 0.8));
            
            return $"#{r:X2}{g:X2}{b:X2}";
        }

        /// <summary>
        /// Tạo button style đẹp
        /// </summary>
        public string CreateButton(string text, string url, string backgroundColor = "#3b82f6", string textColor = "#ffffff")
        {
            return $@"
                <table role='presentation' style='width: 100%; border-collapse: collapse; margin: 24px 0;'>
                    <tr>
                        <td align='center' style='padding: 0;'>
                            <a href='{url}' style='display: inline-block; background-color: {backgroundColor}; color: {textColor}; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 16px; line-height: 1.5; text-align: center; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);'>
                                {text}
                            </a>
                        </td>
                    </tr>
                </table>
            ";
        }

        /// <summary>
        /// Tạo info box
        /// </summary>
        public string CreateInfoBox(string content, string type = "info", string icon = "ℹ️")
        {
            var colors = type switch
            {
                "success" => ("#10b981", "#d1fae5", "#065f46"),
                "warning" => ("#f59e0b", "#fef3c7", "#92400e"),
                "error" => ("#ef4444", "#fee2e2", "#991b1b"),
                "info" => ("#3b82f6", "#eff6ff", "#1e40af"),
                _ => ("#3b82f6", "#eff6ff", "#1e40af")
            };

            return $@"
                <div style='background: {colors.Item2}; border-left: 4px solid {colors.Item1}; border-radius: 8px; padding: 16px; margin: 24px 0;'>
                    <p style='margin: 0; font-size: 14px; color: {colors.Item3}; line-height: 1.6;'>
                        <strong style='display: block; margin-bottom: 4px;'>{icon} {type.ToUpper()}:</strong>
                        {content}
                    </p>
                </div>
            ";
        }

        /// <summary>
        /// Tạo data table đẹp
        /// </summary>
        public string CreateDataTable(Dictionary<string, string> data)
        {
            var rows = new StringBuilder();
            foreach (var item in data)
            {
                rows.Append($@"
                    <tr>
                        <td style='padding: 12px 0; color: #64748b; font-size: 14px; border-bottom: 1px solid #e2e8f0;'>{item.Key}</td>
                        <td style='padding: 12px 0; color: #1e293b; font-size: 14px; font-weight: 600; text-align: right; border-bottom: 1px solid #e2e8f0;'>{item.Value}</td>
                    </tr>
                ");
            }

            return $@"
                <div style='background: #f8fafc; border-radius: 12px; padding: 20px; margin: 24px 0;'>
                    <table style='width: 100%; border-collapse: collapse;'>
                        {rows}
                    </table>
                </div>
            ";
        }
    }
}

