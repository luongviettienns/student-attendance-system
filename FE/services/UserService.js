const API_BASE = "http://localhost:5090/api-edu";
// Nếu gateway chạy HTTPS thì đổi thành:
// const API_BASE = "https://localhost:7033/api-edu";

app.service("UserService", function($http, $window) {

  // 🔹 Helper: lấy token từ localStorage hoặc sessionStorage
  function getToken() {
    return $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
  }

  function authHeader() {
    var token = getToken();
    return token ? { Authorization: "Bearer " + token } : {};
  }

  // 🔹 Normalize avatarUrl → luôn có link hợp lệ
  function normalizeAvatar(url) {
    if (!url) return "assets/img/default-avatar.png";
    if (url.startsWith("http")) return url;

    // ⚠️ nhớ sửa cho đúng base khi chạy thật
    var gatewayBase = "http://localhost:5090";
    // var gatewayBase = "https://localhost:7033";

    return gatewayBase + url; // url kiểu "/uploads/avatars/xxx.png"
  }

  // 🔹 Lấy thông tin user hiện tại (BE đọc từ token)
  this.getProfile = function() {
    return $http.get(`${API_BASE}/users/me`, {
      headers: authHeader()
    }).then(function(response) {
      var user = response.data;
      user.avatarUrl = normalizeAvatar(user.avatarUrl);
      return user; // ⚠️ trả thẳng user object
    });
  };

  // 🔹 Cập nhật profile (FormData: FullName, Email, Phone, Avatar)
  this.updateProfile = function(formData) {
    return $http.put(`${API_BASE}/users/me`, formData, {
      headers: Object.assign({ "Content-Type": undefined }, authHeader()),
      transformRequest: angular.identity // giữ nguyên FormData
    }).then(function(response) {
      // BE trả { message, avatarUrl }
      var result = response.data;
      return {
        message: result.message,
        avatarUrl: normalizeAvatar(result.avatarUrl)
      };
    });
  };

});
