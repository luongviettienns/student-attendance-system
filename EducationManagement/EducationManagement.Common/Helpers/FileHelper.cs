using System;
using System.IO;

namespace EducationManagement.Common.Helpers
{
    public static class FileHelper
    {
        /// <summary>
        /// 🔹 Chuẩn hóa đường dẫn avatar (kiểm tra tồn tại, fallback nếu cần)
        /// </summary>
        /// <param name="avatarUrl">Đường dẫn avatar trong DB (VD: /uploads/avatars/user-001.png)</param>
        /// <param name="avatarFolder">Thư mục gốc chứa Avatar_User</param>
        /// <returns>Đường dẫn tương đối chuẩn hóa (VD: /avatars/default.png)</returns>
        public static string NormalizeAvatarUrl(string? avatarUrl, string avatarFolder)
        {
            if (string.IsNullOrEmpty(avatarUrl))
                return "/avatars/default.png";

            // 🔹 Chuẩn hóa đường dẫn tương thích OS
            string relativePath = avatarUrl.TrimStart('/').Replace('/', Path.DirectorySeparatorChar);
            string physicalPath = Path.Combine(avatarFolder, relativePath);

            // 🔹 Nếu file không tồn tại → trả về ảnh mặc định
            return File.Exists(physicalPath)
                ? $"/{avatarUrl.TrimStart('/')}"
                : "/avatars/default.png";
        }

        /// <summary>
        /// 🔹 Tạo URL đầy đủ cho avatar (qua Gateway)
        /// </summary>
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

            // ✅ Luôn dùng Gateway cố định (đồng bộ FE)
            const string gatewayHost = "localhost:7033";

            return $"{scheme}://{gatewayHost}{relativePath}";
        }

        /// <summary>
        /// 🔹 Trả về đường dẫn vật lý tuyệt đối đến ảnh (dùng khi lưu hoặc xóa file)
        /// </summary>
        public static string BuildPhysicalPath(string fileName)
        {
            // ✅ Khớp với cấu trúc dự án
            var baseFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";

            // ✅ Tạo thư mục nếu chưa tồn tại
            if (!Directory.Exists(baseFolder))
                Directory.CreateDirectory(baseFolder);

            return Path.Combine(baseFolder, fileName);
        }
    }
}
