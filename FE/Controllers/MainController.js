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

  $scope.toggleSubmenu = function(menuLabel) {
    if (!$scope.sidebarOpen && !$scope.isMobile) {
      $scope.sidebarOpen = true;
      $scope.activeMenu = menuLabel;
      return;
    }
    $scope.activeMenu = ($scope.activeMenu === menuLabel) ? null : menuLabel;
  };

  $scope.toggleSidebarMobile = function() {
    if ($scope.isMobile) {
      $scope.sidebarOpen = false;
    }
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

  const resizeHandler = function() { checkScreen(); };
  angular.element($window).on("resize", resizeHandler);
  checkScreen();

  /* ============================================================
     🔹 USER INFORMATION & ROLE CHECK
  ============================================================ */
  const user = AuthService.getUser();

  if (!user) {
    $location.path("/login");
    return;
  }

  $scope.fullName  = user.fullName || "Người dùng";
  $scope.role      = user.role || "Unknown";

  // ✅ Avatar fallback: luôn có ảnh mặc định BE (/avatars/default.png)
  if (user.avatarUrl && user.avatarUrl.trim() !== "") {
    $scope.avatarUrl = user.avatarUrl + "?v=" + Date.now();
  } else {
    $scope.avatarUrl = "https://localhost:7033/avatars/default.png";
  }

  $scope.notificationsCount = 0;

  /* ============================================================
     🔹 CHUYỂN ĐẾN TRANG HỒ SƠ
  ============================================================ */
  $scope.goToProfile = function() {
    $state.go("main.profile");
    if ($scope.isMobile) $scope.sidebarOpen = false;
  };

  /* ============================================================
     🔹 LOAD MENU TỪ BACKEND
  ============================================================ */
  $scope.roleMenus = [];
  $scope.menuLoading = true;

  AuthService.getMenus()
    .then(function(menus) {
      function normalizeState(state) {
        if (!state) return null;
        if (state.startsWith("main.")) return state;
        if (state.startsWith("admin.")) return "main." + state;
        if (state.startsWith("dashboard.")) return "main." + state.replace("dashboard.", "");
        return "main." + state;
      }

      $scope.roleMenus = menus.map(function(m) {
        const mapped = {
          label: m.permissionName || m.label || "Chức năng",
          icon: m.icon || "fa fa-circle",
          state: normalizeState(
            m.state || 
            (m.permissionCode ? m.permissionCode.toLowerCase().replace(/_/g, ".") : null)
          )
        };

        if (m.sub && m.sub.length > 0) {
          mapped.sub = m.sub.map(function(s) {
            return {
              label: s.permissionName || s.label || "Chức năng con",
              icon: s.icon || "fa fa-angle-right",
              state: normalizeState(
                s.state || 
                (s.permissionCode ? s.permissionCode.toLowerCase().replace(/_/g, ".") : null)
              )
            };
          });
        }

        return mapped;
      });
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
      // ✅ Avatar mới từ BE: luôn dạng /avatars/... hoặc full URL
      $scope.avatarUrl = data.avatarUrl + "?t=" + new Date().getTime();
    }

    const storage = $window.localStorage.getItem("currentUser")
      ? $window.localStorage
      : $window.sessionStorage;

    let updatedUser = AuthService.getUser() || {};
    updatedUser.fullName = $scope.fullName;
    updatedUser.role     = $scope.role;

    if (data.avatarUrl) {
      updatedUser.avatarUrl = data.avatarUrl.split("?")[0];
    } else if (!updatedUser.avatarUrl) {
      updatedUser.avatarUrl = "https://localhost:7033/avatars/default.png";
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
