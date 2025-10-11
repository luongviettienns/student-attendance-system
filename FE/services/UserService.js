const API_BASE = "http://localhost:5090/api-edu";
// Nếu Gateway chạy HTTPS thì đổi thành:
// const API_BASE = "https://localhost:7033/api-edu";

app.service("UserService", function($http, $window) {

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
    if (!url) return null; // ❌ Không fallback FE nữa, BE đã có default.png
    if (url.startsWith("http")) return url;

    // ✅ Gateway Base URL
    var gatewayBase = "http://localhost:5090";
    // var gatewayBase = "https://localhost:7033"; // nếu Gateway chạy HTTPS

    return gatewayBase + url; // url kiểu "/uploads/avatars/user-001.png"
  }

  /* ============================================================
     👤 Lấy thông tin user hiện tại (BE đọc từ token)
  ============================================================ */
  this.getProfile = function() {
    return $http.get(`${API_BASE}/users/me`, {
      headers: authHeader()
    }).then(function(response) {
      // BE trả về: { data: { ...userDto... } }
      var user = response.data.data;
      if (user && user.avatarUrl) {
        user.avatarUrl = normalizeAvatar(user.avatarUrl);
      }
      return user;
    });
  };

  /* ============================================================
     ✏️ Cập nhật profile (FormData: FullName, Email, Phone, Avatar)
  ============================================================ */
  this.updateProfile = function(formData) {
    return $http.put(`${API_BASE}/users/me`, formData, {
      headers: Object.assign({ "Content-Type": undefined }, authHeader()),
      transformRequest: angular.identity // giữ nguyên FormData
    }).then(function(response) {
      // BE trả về: { message, data: { avatarUrl: "/uploads/avatars/user-001.png" } }
      var result = response.data;
      var newAvatarUrl = result.data ? normalizeAvatar(result.data.avatarUrl) : null;

      return {
        message: result.message,
        avatarUrl: newAvatarUrl
      };
    });
  };

});
