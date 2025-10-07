angular.module("eduApp").controller("MainController", 
function($scope, $window, $state, $rootScope, $location, AuthService) {

  /* =====================
     🔹 SIDEBAR CONTROL
  ===================== */
  $scope.sidebarOpen = true;      // trạng thái mở / thu gọn
  $scope.isMobile = false;        // chế độ mobile
  $scope.activeMenu = null;       // menu con đang mở (dropdown)

  // === Toggle sidebar ===
  $scope.toggleSidebar = function() {
    if ($scope.isMobile) {
      // 🔹 Mobile: đóng/mở hoàn toàn
      $scope.sidebarOpen = !$scope.sidebarOpen;
    } else {
      // 🔹 Desktop: thu gọn/mở rộng
      $scope.sidebarOpen = !$scope.sidebarOpen;

      // Khi thu gọn → đóng tất cả submenu
      if (!$scope.sidebarOpen) {
        $scope.activeMenu = null;
      }
    }
  };

  // === Toggle submenu ===
  $scope.toggleSubmenu = function(menuName) {
    // Nếu sidebar đang đóng → tự mở ra trước
    if (!$scope.sidebarOpen && !$scope.isMobile) {
      $scope.sidebarOpen = true;
      $scope.activeMenu = menuName;
      return;
    }

    // Ngược lại → bật / tắt submenu
    $scope.activeMenu = ($scope.activeMenu === menuName) ? null : menuName;
  };

  // === Kiểm tra kích thước màn hình ===
  function checkScreen() {
    const wasMobile = $scope.isMobile;
    $scope.isMobile = $window.innerWidth < 992;

    if ($scope.isMobile && !wasMobile) {
      $scope.sidebarOpen = false; // chuyển sang mobile → đóng sidebar
      $scope.activeMenu = null;
    } else if (!$scope.isMobile && wasMobile) {
      $scope.sidebarOpen = true; // quay lại desktop → mở sidebar
    }

    $scope.$applyAsync();
  }

  // Lắng nghe thay đổi kích thước màn hình
  var resizeHandler = function() { checkScreen(); };
  angular.element($window).on("resize", resizeHandler);
  checkScreen();


  /* =====================
     🔹 USER INFORMATION
  ===================== */
  var user = AuthService.getUser();
  if (user) {
    $scope.fullName  = user.fullName;
    $scope.role      = user.role;
    $scope.avatarUrl = user.avatarUrl;
  } else {
    $scope.fullName  = "Sinh viên";
    $scope.role      = "Student";
    $scope.avatarUrl = "assets/img/default-avatar.png";
  }

  // Demo: số lượng thông báo chưa đọc
  $scope.notificationsCount = 3;


  /* =====================
     🔹 LOGOUT
  ===================== */
  $scope.logout = function() {
    AuthService.logout()
      .finally(function() {
        sessionStorage.setItem("justLoggedOut", "true");
        $location.path("/login");
      });
  };


  /* =====================
     🔹 PROFILE UPDATED EVENT
  ===================== */
  $rootScope.$on("profileUpdated", function(event, data) {
    if (data.fullName) {
      $scope.fullName = data.fullName;
    }
    if (data.avatarUrl) {
      // tránh cache hình cũ
      $scope.avatarUrl = data.avatarUrl + "?t=" + new Date().getTime();
    }

    // cập nhật lại user trong AuthService
    var updatedUser = AuthService.getUser() || {};
    updatedUser.fullName = $scope.fullName;
    updatedUser.role     = $scope.role;
    if (data.avatarUrl) {
      updatedUser.avatarUrl = data.avatarUrl.split("?")[0];
    }
    AuthService.setUser(updatedUser);

    $scope.$applyAsync();
  });


  /* =====================
     🔹 CLEANUP
  ===================== */
  $scope.$on("$destroy", function() {
    angular.element($window).off("resize", resizeHandler);
  });

});
