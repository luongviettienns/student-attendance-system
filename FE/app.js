/* ============================================================
   🧩 KHỞI TẠO MODULE CHÍNH CỦA ỨNG DỤNG
============================================================ */
var app = angular.module("eduApp", ["ui.router", "ngFileUpload"]);

/* ============================================================
   ⚙️ CẤU HÌNH ROUTER & GUARD
   → Cấu trúc URL: /main/admin/userAccount
============================================================ */
app.config(function ($stateProvider, $urlRouterProvider) {

  /* ============================================================
     🧩 HÀM BẢO VỆ ROUTE (XÁC THỰC)
  ============================================================ */
  function authGuard(AuthService, $state, $q) {
    if (!AuthService.isAuthenticated()) {
      $state.go("login");
      return $q.reject("Not Authenticated");
    }
    return true;
  }

  /* ============================================================
     🧭 KHAI BÁO CÁC STATE / ROUTE
  ============================================================ */
  $stateProvider

    /* ============================================================
       1️⃣ LOGIN
    ============================================================ */
    .state("login", {
      url: "/login",
      templateUrl: "views/login.html",
      controller: "LoginController"
    })

    /* ============================================================
       2️⃣ MAIN LAYOUT (CHA)
    ============================================================ */
    .state("main", {
      url: "/main",
      templateUrl: "views/main.html",
      controller: "MainController",
      resolve: { auth: authGuard }
    })

    /* ============================================================
       3️⃣ DASHBOARD CHÍNH (WELCOME)
    ============================================================ */
    .state("main.welcome", {
      url: "/welcome",
      templateUrl: "views/welcome.html",
      resolve: { auth: authGuard }
    })

    /* ============================================================
       4️⃣ ADMIN MODULE
       → Có state cha riêng `main.admin` chứa <ui-view>
    ============================================================ */
    .state("main.admin", {
      url: "/admin",
      template: "<div ui-view></div>",
      resolve: { auth: authGuard }
    })

      // === Các trang con của ADMIN ===
      .state("main.admin.userAccount", {
        url: "/userAccount",
        templateUrl: "views/admin/account.html",
        controller: "AccountController",
        resolve: { auth: authGuard }
      })

      .state("main.admin.roleManage", {
        url: "/roleManage",
        templateUrl: "views/admin/role-manage.html",
        controller: "RoleManageController",
        resolve: { auth: authGuard }
      })

      .state("main.admin.rolePermission", {
        url: "/rolePermission",
        templateUrl: "views/admin/role-permission.html",
        controller: "RolePermissionController",
        resolve: { auth: authGuard }
      })

    /* ============================================================
       5️⃣ TEACHER / STUDENT / ADVISOR MODULES
       → Dễ mở rộng sau này
    ============================================================ */
    .state("main.teacher", {
      url: "/teacher",
      template: "<div ui-view></div>",
      resolve: { auth: authGuard }
    })

      .state("main.teacher.classView", {
        url: "/classView",
        templateUrl: "views/teacher/class-view.html",
        controller: "TeacherClassController",
        resolve: { auth: authGuard }
      })

    .state("main.student", {
      url: "/student",
      template: "<div ui-view></div>",
      resolve: { auth: authGuard }
    })

      .state("main.student.scheduleView", {
        url: "/scheduleView",
        templateUrl: "views/student/schedule-view.html",
        controller: "StudentScheduleController",
        resolve: { auth: authGuard }
      })

    .state("main.advisor", {
      url: "/advisor",
      template: "<div ui-view></div>",
      resolve: { auth: authGuard }
    })

      .state("main.advisor.attendanceTrack", {
        url: "/attendanceTrack",
        templateUrl: "views/advisor/attendance-track.html",
        controller: "AdvisorAttendanceController",
        resolve: { auth: authGuard }
      })

    /* ============================================================
       6️⃣ PROFILE CHUNG
    ============================================================ */
    .state("main.profile", {
      url: "/profile",
      templateUrl: "views/profile.html",
      controller: "ProfileController",
      resolve: { auth: authGuard }
    });

  /* ============================================================
     7️⃣ URL MẶC ĐỊNH
  ============================================================ */
  $urlRouterProvider.otherwise("/login");
});


/* ============================================================
   🚀 KHỞI ĐỘNG ỨNG DỤNG (GLOBAL + ROLE GUARD + LOGIN REDIRECT)
============================================================ */
app.run(function ($transitions, $state, AuthService, $rootScope, ToastService) {

  // Gán ToastService toàn cục
  $rootScope.ToastService = ToastService;

  // Nếu đã login mà vẫn vào /login → chuyển về dashboard chính
  $transitions.onStart({ to: "login" }, function () {
    if (AuthService.isAuthenticated()) {
      const user = AuthService.getUser();
      const role = (user?.role || "").toLowerCase();
      if (role === "admin") {
        return $state.target("main.welcome");
      }
      ToastService.show("Tài khoản này chưa được cấu hình trang riêng.", "info");
    }
  });

  // Theo dõi trạng thái đăng nhập
  $rootScope.isAuthenticated = AuthService.isAuthenticated();
  $rootScope.$on("auth:logout", () => $rootScope.isAuthenticated = false);
  $rootScope.$on("auth:login",  () => $rootScope.isAuthenticated = true);
});
