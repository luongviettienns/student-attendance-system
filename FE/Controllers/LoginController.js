angular.module("eduApp").controller("LoginController", 
function($scope, $location, AuthService, ToastService) {
  $scope.errorMessage = "";
  $scope.rememberMe = false;
  $scope.form = { username: "", password: "" };

  // 🔹 Nếu vừa logout thì show thông báo
  if (sessionStorage.getItem("justLoggedOut") === "true") {
    ToastService.show("Bạn đã đăng xuất thành công!", "info");
    sessionStorage.removeItem("justLoggedOut");
  }

  // 🔹 Hàm login
  $scope.login = function() {
    if (!$scope.form.username || !$scope.form.password) {
      $scope.errorMessage = "Vui lòng nhập đầy đủ tài khoản và mật khẩu";
      return;
    }

    AuthService.login($scope.form.username, $scope.form.password, $scope.rememberMe)
      .then(function(data) {
        if (data && data.token) {
          var role = data.role || "User";
          var fullName = data.fullName || "";

          // ✅ Hiện toast chào mừng
          ToastService.show(
            `Chào mừng ${role} ${fullName} quay lại hệ thống 🎉`,
            "success"
          );

          // ✅ Tất cả role đều về chung 1 dashboard
          $location.path("/main/dashboard");
        } else {
          $scope.errorMessage = "Đăng nhập thất bại, vui lòng thử lại.";
        }
      })
      .catch(function(err) {
        console.error("Login error:", err);
        $scope.errorMessage = "Sai tài khoản hoặc mật khẩu";
      });
  };

  // 🔹 Nếu đã login → tự redirect vào dashboard
  (function init() {
    if (AuthService.isAuthenticated()) {
      $location.path("/main/dashboard");
    }
  })();
});
