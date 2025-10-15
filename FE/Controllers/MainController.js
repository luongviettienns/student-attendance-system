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
    // 🚫 Chưa đăng nhập → về login
    $location.path("/login");
    return;
  }

  $scope.fullName  = user.fullName || "Người dùng";
  $scope.role      = user.role || "Unknown";
  $scope.avatarUrl = user.avatarUrl ? (user.avatarUrl + "?v=" + Date.now()) : null;

  $scope.notificationsCount = 0;


  /* ============================================================
     🔹 HÀM CHUYỂN ĐẾN TRANG HỒ SƠ (PROFILE)
  ============================================================ */
  $scope.goToProfile = function() {
    $state.go("main.profile");
    if ($scope.isMobile) $scope.sidebarOpen = false;
  };


  /* ============================================================
     🔹 SIDEBAR MENU (LOAD TỪ BACKEND)
  ============================================================ */
  $scope.roleMenus = [];
  $scope.menuLoading = true;

  AuthService.getMenus()
    .then(function(menus) {
      console.log("✅ Raw menus from BE:", menus);

      // 🧩 Hàm chuẩn hóa state từ BE sang FE
      function normalizeState(state) {
        if (!state) return null;

        // Nếu state đã bắt đầu bằng "main." thì giữ nguyên
        if (state.startsWith("main.")) return state;

        // Nếu BE trả "admin.xxx" → chuyển thành "main.admin.xxx"
        if (state.startsWith("admin.")) return "main." + state;

        // Nếu BE trả "dashboard.xxx" → chuyển thành "main.xxx"
        if (state.startsWith("dashboard.")) return "main." + state.replace("dashboard.", "");

        // Ngược lại giữ nguyên
        return state;
      }

      // Map dữ liệu menu từ BE sang FE
      $scope.roleMenus = menus.map(function(m) {
        const mapped = {
          label: m.permissionName || m.label || "Chức năng",
          icon: m.icon || "fa fa-circle",
          state: normalizeState(m.state || (m.permissionCode ? m.permissionCode.toLowerCase().replace(/_/g, ".") : null))
        };

        if (m.sub && m.sub.length > 0) {
          mapped.sub = m.sub.map(function(s) {
            return {
              label: s.permissionName || s.label || "Chức năng con",
              icon: s.icon || "fa fa-angle-right",
              state: normalizeState(s.state || (s.permissionCode ? s.permissionCode.toLowerCase().replace(/_/g, ".") : null))
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
