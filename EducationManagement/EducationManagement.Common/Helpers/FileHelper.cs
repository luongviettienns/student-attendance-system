namespace EducationManagement.Common.Helpers
{
    public static class FileHelper
    {
        public static string BuildFullAvatarUrl(string scheme, string host, string? avatarUrl)
        {
            var url = string.IsNullOrWhiteSpace(avatarUrl)
                ? "/uploads/avatars/default.png"
                : avatarUrl;

            return $"{scheme}://{host}{url}";
        }
    }
}


