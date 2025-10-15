/* ============================================================
   🧩 KHỞI TẠO MODULE CHÍNH CỦA ỨNG DỤNG
============================================================ */
var app = angular.module("eduApp", ["ui.router", "ngFileUpload"]);

/* ============================================================
   ⚙️ CẤU HÌNH ROUTER & GUARD
   → Cấu trúc URL: /main/admin/account
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
       3️⃣ TRANG CHÀO MỪNG (THAY THẾ DASHBOARD)
    ============================================================ */
    .state("main.welcome", {
      url: "/welcome",
      templateUrl: "views/welcome.html",
      resolve: { auth: authGuard }
    })

    /* ============================================================
       4️⃣ ADMIN MODULE
    ============================================================ */
    .state("main.admin", {
      url: "/admin",
      abstract: true,
      template: "<ui-view></ui-view>",
      resolve: { auth: authGuard }
    })

    .state("main.admin.account", {
      url: "/account",
      templateUrl: "views/admin/account.html",
      controller: "AccountController",
      resolve: { auth: authGuard }
    })

    .state("main.admin.roleManage", {
      url: "/role/manage",
      templateUrl: "views/admin/role-manage.html",
      controller: "RoleManageController",
      resolve: { auth: authGuard }
    })

    .state("main.admin.rolePermission", {
      url: "/role/permission",
      templateUrl: "views/admin/role-permission.html",
      controller: "RolePermissionController",
      resolve: { auth: authGuard }
    })

    /* ============================================================
       5️⃣ MODULE KHÁC
    ============================================================ */
    .state("main.profile", {
      url: "/profile",
      templateUrl: "views/profile.html",
      controller: "ProfileController",
      resolve: { auth: authGuard }
    })

    .state("main.student", {
      url: "/student",
      templateUrl: "views/student.html",
      controller: "StudentController",
      resolve: { auth: authGuard }
    })

    .state("main.teacher", {
      url: "/teacher",
      templateUrl: "views/teacher.html",
      controller: "TeacherController",
      resolve: { auth: authGuard }
    })

    .state("main.advisor", {
      url: "/advisor",
      templateUrl: "views/advisor.html",
      controller: "AdvisorController",
      resolve: { auth: authGuard }
    });

  /* ============================================================
     6️⃣ URL MẶC ĐỊNH
  ============================================================ */
  $urlRouterProvider.otherwise("/login");
});


/* ============================================================
   🚀 KHỞI ĐỘNG ỨNG DỤNG (ROLE GUARD + LOGIN REDIRECT)
============================================================ */
app.run(function ($transitions, $state, AuthService, $rootScope, ToastService) {

  /* ============================================================
     🔹 Nếu đã login mà vẫn vào /login → tự chuyển về trang chào mừng
  ============================================================ */
  $transitions.onStart({ to: "login" }, function () {
    if (AuthService.isAuthenticated()) {
      const user = AuthService.getUser();
      const role = (user?.role || "").toLowerCase();
      if (role === "admin") {
        return $state.target("main.welcome"); // ✅ Chuyển sang trang chào mừng
      }
      ToastService.show("Tài khoản này chưa được cấu hình trang riêng.", "info");
    }
  });

  /* ============================================================
     🔹 Theo dõi trạng thái đăng nhập toàn cục
  ============================================================ */
  $rootScope.isAuthenticated = AuthService.isAuthenticated();

  $rootScope.$on("auth:logout", function () {
    $rootScope.isAuthenticated = false;
  });

  $rootScope.$on("auth:login", function () {
    $rootScope.isAuthenticated = true;
  });
});
