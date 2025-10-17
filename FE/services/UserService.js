angular.module("eduApp")

.service("UserService", function ($http, $window) {

  // ============================================================
  // 🔹 BASE CONFIG – Qua Gateway (HTTPS / HTTP tùy cổng bạn chạy)
  // ============================================================
  const API_BASE = "https://localhost:7033/api-edu"; // ✅ Gateway chuẩn (cùng AuthService)

  // ============================================================
  // 🔹 Token & Header Helpers
  // ============================================================
  const getToken = () =>
    $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");

  const authHeader = () => {
    const token = getToken();
    return token ? { Authorization: "Bearer " + token } : {};
  };

  // ============================================================
  // 🔹 Chuẩn hóa avatar URL (qua Gateway)
  // ============================================================
  const normalizeAvatar = (url) => {
    const gatewayBase = API_BASE.replace("/api-edu", ""); // → https://localhost:7033
    if (!url) return `${gatewayBase}/avatars/default.png`;
    if (url.startsWith("http")) return url;
    return `${gatewayBase}${url}`; // "/avatars/user-001.png" → "https://localhost:7033/avatars/user-001.png"
  };

  // ============================================================
  // 👤 Lấy thông tin người dùng hiện tại (đọc từ token)
  // ============================================================
  this.getProfile = async () => {
    try {
      const res = await $http.get(`${API_BASE}/users/me`, { headers: authHeader() });
      const user = res.data?.data;
      user.avatarUrl = normalizeAvatar(user?.avatarUrl);
      return user;
    } catch (err) {
      console.error("❌ Lỗi khi tải thông tin người dùng:", err);
      throw err;
    }
  };

  // ============================================================
  // ✏️ Cập nhật hồ sơ (FormData: FullName, Email, Phone, Avatar)
  // ============================================================
  this.updateProfile = async (formData) => {
    try {
      const res = await $http.put(`${API_BASE}/users/me`, formData, {
        headers: { ...authHeader(), "Content-Type": undefined },
        transformRequest: angular.identity // giữ nguyên FormData
      });

      const result = res.data;
      const newAvatarUrl = normalizeAvatar(result?.data?.avatarUrl);

      return {
        message: result.message || "Cập nhật thành công",
        avatarUrl: newAvatarUrl
      };
    } catch (err) {
      console.error("❌ Lỗi khi cập nhật hồ sơ:", err);
      throw err;
    }
  };
});
