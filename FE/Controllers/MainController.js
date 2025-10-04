angular.module("eduApp").controller("MainController", 
function($scope, $window, $state, $rootScope, $location, AuthService) {
  // Sidebar control
  $scope.sidebarOpen = true;
  $scope.isMobile = false;

  // Hàm toggle sidebar
  $scope.toggleSidebar = function() {
    $scope.sidebarOpen = !$scope.sidebarOpen;
  };

  // Hàm kiểm tra màn hình và set trạng thái sidebar
  function checkScreen() {
    $scope.isMobile = $window.innerWidth < 768; 
    // Nếu mobile thì sidebar đóng, desktop thì mở
    $scope.sidebarOpen = !$scope.isMobile;      
    $scope.$applyAsync();
  }

  var resizeHandler = function() { checkScreen(); };
  angular.element($window).on("resize", resizeHandler);
  checkScreen();

  // 🔹 Lấy user từ AuthService (luôn đọc từ đúng storage)
  var user = AuthService.getUser();
  $scope.fullName  = user.fullName;
  $scope.role      = user.role;
  $scope.avatarUrl = user.avatarUrl;

  // (demo) số lượng thông báo
  $scope.notificationsCount = 3;

  // 🔹 Logout
  $scope.logout = function() {
    AuthService.logout()
      .finally(function() {
        // Đặt cờ để login page hiển thị thông báo
        sessionStorage.setItem("justLoggedOut", "true");
        $location.path("/login");
      });
  };

  // 🔹 Lắng nghe sự kiện khi profile được update
  $rootScope.$on("profileUpdated", function(event, data) {
    if (data.fullName) {
      $scope.fullName = data.fullName;
    }
    if (data.avatarUrl) {
      // dùng ?t= chỉ cho UI để tránh cache
      $scope.avatarUrl = data.avatarUrl + "?t=" + new Date().getTime();
    }

    // 🔹 Cập nhật lại storage qua AuthService (lưu URL sạch, không có ?t=)
    var updatedUser = AuthService.getUser();
    updatedUser.fullName = $scope.fullName;
    updatedUser.role     = $scope.role;
    if (data.avatarUrl) {
      updatedUser.avatarUrl = data.avatarUrl.split("?")[0];
    }
    AuthService.setUser(updatedUser);

    $scope.$applyAsync();
  });

  // Cleanup
  $scope.$on("$destroy", function() {
    angular.element($window).off("resize", resizeHandler);
  });
});
