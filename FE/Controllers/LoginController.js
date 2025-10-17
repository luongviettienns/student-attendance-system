angular.module("eduApp").controller("LoginController", 
function ($scope, $state, $rootScope, AuthService, ToastService, $timeout) {

  /* ============================================================
     🔹 STATE
  ============================================================ */
  $scope.errorMessage = "";
  $scope.rememberMe = false;
  $scope.form = { username: "", password: "" };

  /* ============================================================
     🔹 Thông báo sau khi logout
  ============================================================ */
  if (sessionStorage.getItem("justLoggedOut") === "true") {
    ToastService.show("Bạn đã đăng xuất thành công!", "info");
    sessionStorage.removeItem("justLoggedOut");
  }

  /* ============================================================
     🔹 Hàm LOGIN
  ============================================================ */
  $scope.login = function () {
    if (!$scope.form.username || !$scope.form.password) {
      $scope.errorMessage = "Vui lòng nhập đầy đủ tài khoản và mật khẩu";
      return;
    }

    AuthService.login($scope.form.username, $scope.form.password, $scope.rememberMe)
      .then(function (data) {
        if (data && data.token) {
          const role = (data.role || "").toLowerCase();
          const fullName = data.fullName || "";

          ToastService.show(
            `Chào mừng ${data.role || "Người dùng"} ${fullName} quay lại hệ thống 🎉`,
            "success"
          );

          $rootScope.$emit("auth:login");

          // ✅ Chuyển hướng theo vai trò
          const targetState = AuthService.redirectAfterLogin(role);

          if (targetState && targetState !== "login") {
            // 🟢 Delay nhẹ để guard nhận token trước khi chuyển state
            $timeout(() => {
              $state.go(targetState);
            }, 100);
          } else {
            ToastService.show(
              "Đăng nhập thành công, nhưng chưa được cấu hình màn hình cho vai trò này.",
              "info"
            );
          }
        } else {
          $scope.errorMessage = "Đăng nhập thất bại, vui lòng thử lại.";
        }
      })
      .catch(function (err) {
        console.error("❌ Login error:", err);
        $scope.errorMessage =
          err?.message ||
          err?.data?.message ||
          err?.response?.data?.message ||
          "Sai tài khoản hoặc mật khẩu";
      });
  };

  /* ============================================================
     🔹 Nếu đã đăng nhập sẵn → Tự chuyển đến màn hình phù hợp
  ============================================================ */
  (function init() {
    if (AuthService.isAuthenticated()) {
      const user = AuthService.getUser();
      const role = (user?.role || "").toLowerCase();

      const targetState = AuthService.redirectAfterLogin(role);
      if (targetState && targetState !== "login") {
        $state.go(targetState);
      } else {
        ToastService.show(
          "Bạn đã đăng nhập, nhưng chưa được cấu hình trang riêng.",
          "info"
        );
      }
    }
  })();
});
