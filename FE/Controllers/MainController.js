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
      $scope.sidebarOpen = !$scope.sidebarOpen;
    } else {
      $scope.sidebarOpen = !$scope.sidebarOpen;
      if (!$scope.sidebarOpen) $scope.activeMenu = null;
    }
  };

  // === Toggle submenu ===
  $scope.toggleSubmenu = function(menuName) {
    if (!$scope.sidebarOpen && !$scope.isMobile) {
      $scope.sidebarOpen = true;
      $scope.activeMenu = menuName;
      return;
    }
    $scope.activeMenu = ($scope.activeMenu === menuName) ? null : menuName;
  };

  // === Kiểm tra kích thước màn hình ===
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

  // Demo thông báo
  $scope.notificationsCount = 3;


  /* =====================
     🔹 SIDEBAR MENU THEO ROLE
  ===================== */
  $scope.menus = {
    Admin: [
      { icon: "fa-home", label: "Trang chủ", state: "admin.dashboard" },
      { icon: "fa-users-cog", label: "Quản lý tài khoản", state: "main.userManagement" },  // ✅ Đổi tên + route
      {
        icon: "fa-book",
        label: "Quản lý đào tạo",
        sub: [
          { label: "Danh mục môn học", state: "admin.subjects" },
          { label: "Lớp học", state: "admin.classes" },
          { label: "Niên khóa", state: "admin.academicyears" }
        ]
      },
      { icon: "fa-chart-line", label: "Báo cáo & Thống kê", state: "admin.reports" }
    ],

    Student: [
      { icon: "fa-home", label: "Trang chủ", state: "student.dashboard" },
      {
        icon: "fa-book",
        label: "Học tập",
        sub: [
          { label: "Lịch học", state: "student.schedule" },
          { label: "Đăng ký học phần", state: "student.enrollment" },
          { label: "Điểm danh", state: "student.attendance" },
          { label: "Kết quả & GPA", state: "student.results" },
          { label: "Phúc khảo điểm", state: "student.appeals" }
        ]
      },
      {
        icon: "fa-user",
        label: "Cá nhân",
        sub: [
          { label: "Hồ sơ sinh viên", state: "student.profile" },
          { label: "Người thân", state: "student.family" }
        ]
      }
    ]
  };

  // 🔸 Các role khác (Lecturer, Advisor) có thể thêm sau:
  // $scope.menus.Lecturer = [ ... ];
  // $scope.menus.Advisor = [ ... ];


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


  /* =====================
     🔹 CLEANUP
  ===================== */
  $scope.$on("$destroy", function() {
    angular.element($window).off("resize", resizeHandler);
  });

});
