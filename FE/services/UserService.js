// ============================================================
// 🔹 BASE CONFIG – Dùng Gateway làm đầu mối duy nhất
// ============================================================
const API_BASE = "https://localhost:7033/api-edu"; // ✅ Gateway HTTPS

app.service("UserService", function ($http, $window) {

  /* ============================================================
     🔹 Helper: Lấy token từ localStorage hoặc sessionStorage
  ============================================================ */
  function getToken() {
    return $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
  }

  function authHeader() {
    var token = getToken();
    return token ? { Authorization: "Bearer " + token } : {};
  }

  /* ============================================================
     🔹 Chuẩn hóa avatarUrl → luôn trỏ qua Gateway
  ============================================================ */
  function normalizeAvatar(url) {
    if (!url) return API_BASE.replace("/api-edu", "") + "/avatars/default.png"; // fallback ảnh mặc định
    if (url.startsWith("http")) return url;

    // ✅ Gateway Base URL (đồng bộ với AuthService)
    var gatewayBase = API_BASE.replace("/api-edu", "");
    // → kết quả: "https://localhost:7033"

    return gatewayBase + url; // url kiểu "/avatars/user-001.png"
  }

  /* ============================================================
     👤 Lấy thông tin user hiện tại (BE đọc từ token)
  ============================================================ */
  this.getProfile = function () {
    return $http.get(`${API_BASE}/users/me`, {
      headers: authHeader()
    }).then(function (response) {
      // BE trả về: { data: { ...userDto... } }
      var user = response.data.data;
      if (user && user.avatarUrl) {
        user.avatarUrl = normalizeAvatar(user.avatarUrl);
      } else {
        user.avatarUrl = normalizeAvatar(null); // fallback default
      }
      return user;
    });
  };

  /* ============================================================
     ✏️ Cập nhật profile (FormData: FullName, Email, Phone, Avatar)
  ============================================================ */
  this.updateProfile = function (formData) {
    return $http.put(`${API_BASE}/users/me`, formData, {
      headers: Object.assign({ "Content-Type": undefined }, authHeader()),
      transformRequest: angular.identity // giữ nguyên FormData
    }).then(function (response) {
      // BE trả về: { message, data: { avatarUrl: "/avatars/user-001.png" } }
      var result = response.data;
      var newAvatarUrl = result.data ? normalizeAvatar(result.data.avatarUrl) : null;

      return {
        message: result.message,
        avatarUrl: newAvatarUrl
      };
    });
  };

});
