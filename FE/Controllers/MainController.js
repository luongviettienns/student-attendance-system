angular.module("eduApp").controller("MainController",
function($scope, $window, $state, $rootScope, $location, AuthService) {

  /* ============================================================
     🔹 SIDEBAR CONTROL
  ============================================================ */
  $scope.sidebarOpen = true;
  $scope.isMobile = false;
  $scope.activeMenu = null;

  $scope.toggleSidebar = function() {
    if ($scope.isMobile) {
      $scope.sidebarOpen = !$scope.sidebarOpen;
    } else {
      $scope.sidebarOpen = !$scope.sidebarOpen;
      if (!$scope.sidebarOpen) $scope.activeMenu = null;
    }
  };

  $scope.toggleSubmenu = function(menuName) {
    if (!$scope.sidebarOpen && !$scope.isMobile) {
      $scope.sidebarOpen = true;
      $scope.activeMenu = menuName;
      return;
    }
    $scope.activeMenu = ($scope.activeMenu === menuName) ? null : menuName;
  };

  function checkScreen() {
    const wasMobile = $scope.isMobile;
    $scope.isMobile = $window.innerWidth < 992;

    if ($scope.isMobile && !wasMobile) {
      $scope.sidebarOpen = false;
      $scope.activeMenu = null;
    } else if (!$scope.isMobile && wasMobile) {
      $scope.sidebarOpen = true;
    }

    $scope.$applyAsync();
  }

  var resizeHandler = function() { checkScreen(); };
  angular.element($window).on("resize", resizeHandler);
  checkScreen();


  /* ============================================================
     🔹 USER INFORMATION
  ============================================================ */
  const user = AuthService.getUser();

  if (user) {
    $scope.fullName  = user.fullName || "Người dùng";
    $scope.role      = user.role || "Unknown";
    $scope.avatarUrl = user.avatarUrl ? (user.avatarUrl + "?v=" + Date.now()) : null;
  } else {
    $scope.fullName  = "Khách";
    $scope.role      = "Guest";
    $scope.avatarUrl = null;
  }

  $scope.notificationsCount = 0;


  /* ============================================================
     🔹 SIDEBAR MENU - DỮ LIỆU TỪ BE
  ============================================================ */
  $scope.roleMenus = [];
  $scope.menuLoading = true;

  AuthService.getMenus()
    .then(function(menus) {
      console.log("✅ Menu data from BE:", menus); // Debug dữ liệu gốc

      // Map dữ liệu trả về từ BE thành cấu trúc hiển thị FE
      $scope.roleMenus = menus.map(function(m) {
        return {
          icon: "fa-circle", // icon mặc định, có thể map theo permissionCode sau
          label: m.permissionName || "Chức năng",
          state: m.permissionCode
            ? m.permissionCode.toLowerCase().replace(/_/g, ".")
            : "home"
        };
      });

      console.log("✅ Mapped menus for sidebar:", $scope.roleMenus);
    })
    .catch(function(err) {
      console.error("❌ Load menu failed:", err);
    })
    .finally(function() {
      $scope.menuLoading = false;
      $scope.$applyAsync();
    });


  /* ============================================================
     🔹 LOGOUT
  ============================================================ */
  $scope.logout = function() {
    AuthService.logout()
      .finally(function() {
        sessionStorage.setItem("justLoggedOut", "true");
        $location.path("/login");
      });
  };


  /* ============================================================
     🔹 PROFILE UPDATED EVENT
  ============================================================ */
  $rootScope.$on("profileUpdated", function(event, data) {
    if (data.fullName) $scope.fullName = data.fullName;
    if (data.avatarUrl) {
      $scope.avatarUrl = data.avatarUrl + "?t=" + new Date().getTime();
    }

    var updatedUser = AuthService.getUser() || {};
    updatedUser.fullName = $scope.fullName;
    updatedUser.role     = $scope.role;
    if (data.avatarUrl) {
      updatedUser.avatarUrl = data.avatarUrl.split("?")[0];
    }
    AuthService.setUser(updatedUser);

    $scope.$applyAsync();
  });


  /* ============================================================
     🔹 CLEANUP
  ============================================================ */
  $scope.$on("$destroy", function() {
    angular.element($window).off("resize", resizeHandler);
  });

});
