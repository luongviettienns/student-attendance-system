angular.module("eduApp").controller("MainController",
function($scope, $window, $state, $rootScope, $location, AuthService) {

  /* ============================================================
     🔹 SIDEBAR CONTROL
  ============================================================ */
  $scope.sidebarOpen = true;
  $scope.isMobile = false;
  $scope.activeMenu = null;

  // Toggle sidebar
  $scope.toggleSidebar = function() {
    if ($scope.isMobile) {
      $scope.sidebarOpen = !$scope.sidebarOpen;
    } else {
      $scope.sidebarOpen = !$scope.sidebarOpen;
      if (!$scope.sidebarOpen) $scope.activeMenu = null;
    }
  };

  // Toggle submenu
  $scope.toggleSubmenu = function(menuLabel) {
    if (!$scope.sidebarOpen && !$scope.isMobile) {
      $scope.sidebarOpen = true;
      $scope.activeMenu = menuLabel;
      return;
    }
    $scope.activeMenu = ($scope.activeMenu === menuLabel) ? null : menuLabel;
  };

  // Detect responsive
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
     🔹 SIDEBAR MENU (LOAD TỪ BACKEND)
  ============================================================ */
  $scope.roleMenus = [];
  $scope.menuLoading = true;

  AuthService.getMenus()
    .then(function(menus) {
      console.log("✅ Raw menus from BE:", menus);

      // === Map dữ liệu menu ===
      $scope.roleMenus = menus.map(function(m) {
        const mapped = {
          label: m.permissionName || m.label || "Chức năng",
          icon: m.icon || "fa fa-circle",
          state: m.state || (m.permissionCode ? m.permissionCode.toLowerCase().replace(/_/g, ".") : null)
        };

        // Nếu có submenu
        if (m.sub && m.sub.length > 0) {
          mapped.sub = m.sub.map(function(s) {
            return {
              label: s.permissionName || s.label || "Chức năng con",
              icon: s.icon || "fa fa-angle-right",
              state: s.state || (s.permissionCode ? s.permissionCode.toLowerCase().replace(/_/g, ".") : null)
            };
          });
        }
        return mapped;
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

    // cập nhật lại currentUser trong storage
    const storage = $window.localStorage.getItem("currentUser")
      ? $window.localStorage
      : $window.sessionStorage;

    let updatedUser = AuthService.getUser() || {};
    updatedUser.fullName = $scope.fullName;
    updatedUser.role     = $scope.role;
    if (data.avatarUrl) {
      updatedUser.avatarUrl = data.avatarUrl.split("?")[0];
    }
    storage.setItem("currentUser", JSON.stringify(updatedUser));

    $scope.$applyAsync();
  });


  /* ============================================================
     🔹 CLEANUP
  ============================================================ */
  $scope.$on("$destroy", function() {
    angular.element($window).off("resize", resizeHandler);
  });

});
