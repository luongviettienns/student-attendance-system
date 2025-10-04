app.controller("DashboardController", function($scope, $location, AuthService, ToastService) {
  // Nếu chưa đăng nhập thì đưa về login
  if (!AuthService.isAuthenticated()) {
    $location.path("/login");
    return;
  }

  // Thông tin user
  $scope.user = {
    fullName: AuthService.getFullName(),
    role: AuthService.getRole()
  };

  $scope.logout = function() {
    AuthService.logout()
      .then(function() {
        console.log("Logout API success");
      })
      .catch(function(err) {
        console.error("Logout API error:", err);
      })
      .finally(function() {
        // Đặt cờ để LoginController hiển thị thông báo
        sessionStorage.setItem("justLoggedOut", "true");
        $location.path("/login");
      });
  };
});
