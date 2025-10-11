using System;

namespace EducationManagement.Common.Helpers
{
    public static class FileHelper
    {
        /// <summary>
        /// Tạo URL đầy đủ cho avatar thông qua Gateway (http://localhost:5090)
        /// </summary>
        /// <param name="scheme">Scheme (http hoặc https)</param>
        /// <param name="host">Host của request hiện tại</param>
        /// <param name="relativePath">Đường dẫn ảnh (vd: /uploads/avatars/user-001.png)</param>
        /// <returns>Đường dẫn URL đầy đủ qua Gateway</returns>
        public static string BuildFullAvatarUrl(string scheme, string host, string? relativePath)
        {
            // ✅ Nếu đường dẫn trống hoặc null → trả về ảnh mặc định
            if (string.IsNullOrEmpty(relativePath))
                relativePath = "/uploads/avatars/default.png";

            // ✅ Đảm bảo không có dấu // thừa
            if (!relativePath.StartsWith("/"))
                relativePath = "/" + relativePath;

            // ✅ Gateway luôn chạy ở cổng 5090
            var gatewayBaseUrl = "http://localhost:5090";

            // ✅ Ghép đường dẫn đầy đủ
            return $"{gatewayBaseUrl}{relativePath}";
        }

        /// <summary>
        /// Tạo đường dẫn tuyệt đối trên ổ đĩa (dành cho lưu file, xóa file)
        /// </summary>
        public static string BuildPhysicalPath(string fileName)
        {
            var baseFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";
            return Path.Combine(baseFolder, fileName);
        }
    }
}
