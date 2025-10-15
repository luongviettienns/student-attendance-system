using System;
using System.IO;

namespace EducationManagement.Common.Helpers
{
    public static class FileHelper
    {
        /// <summary>
        /// 🔹 Tạo URL đầy đủ cho ảnh avatar (phục vụ qua Gateway /avatars/)
        /// </summary>
        /// <param name="scheme">Scheme (http hoặc https)</param>
        /// <param name="host">Host hiện tại (VD: localhost:7033)</param>
        /// <param name="relativePath">Đường dẫn tương đối (VD: user-001.png hoặc /avatars/user-001.png)</param>
        /// <returns>URL đầy đủ cho FE</returns>
        public static string BuildFullAvatarUrl(string scheme, string host, string? relativePath)
        {
            // ✅ Nếu user chưa có ảnh → fallback mặc định
            if (string.IsNullOrWhiteSpace(relativePath))
                relativePath = "/avatars/default.png";

            // ✅ Nếu chỉ là tên file (VD: "user-001.jpg") → thêm prefix /avatars/
            if (!relativePath.StartsWith("/avatars/", StringComparison.OrdinalIgnoreCase))
            {
                relativePath = relativePath.TrimStart('/');
                relativePath = "/avatars/" + relativePath;
            }

            // ✅ Đảm bảo có dấu "/" đầu
            if (!relativePath.StartsWith("/"))
                relativePath = "/" + relativePath;

            // ✅ Luôn sử dụng gateway host cố định (Gateway API)
            const string gatewayHost = "localhost:7033";

            // ✅ Ghép URL đầy đủ
            return $"{scheme}://{gatewayHost}{relativePath}";
        }

        /// <summary>
        /// 🔹 Trả về đường dẫn vật lý tuyệt đối đến ảnh (dùng khi lưu, xoá file)
        /// </summary>
        /// <param name="fileName">Tên file (VD: user-001.png)</param>
        /// <returns>Đường dẫn tuyệt đối</returns>
        public static string BuildPhysicalPath(string fileName)
        {
            // ✅ Khớp với cấu hình trong Program.cs
            var baseFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";

            // ✅ Tạo thư mục nếu chưa tồn tại
            if (!Directory.Exists(baseFolder))
                Directory.CreateDirectory(baseFolder);

            return Path.Combine(baseFolder, fileName);
        }
    }
}
