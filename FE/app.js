/* ============================================================
   🧩 Khởi tạo module chính của ứng dụng
============================================================ */
var app = angular.module("eduApp", ["ui.router", "ngFileUpload"]);

/* ============================================================
   ⚙️ CẤU HÌNH CHÍNH: Routing + HTTP + Guard
============================================================ */
app.config(function ($stateProvider, $urlRouterProvider) {

    /* ============================================================
       1️⃣ Hàm bảo vệ route
    ============================================================ */
    function authGuard(AuthService, $state, $q) {
        if (!AuthService.isAuthenticated()) {
            $state.go("login");
            return $q.reject("Not Authenticated");
        }
        return true;
    }

    /* ============================================================
       2️⃣ Cấu hình routing
    ============================================================ */
    $stateProvider

        // ===== LOGIN =====
        .state("login", {
            url: "/login",
            templateUrl: "views/login.html",
            controller: "LoginController"
        })

        // ===== MAIN LAYOUT =====
        .state("main", {
            url: "/main",
            templateUrl: "views/main.html",
            controller: "MainController",
            resolve: { auth: authGuard }
        })

        // ===== DASHBOARD =====
        .state("main.dashboard", {
            url: "/dashboard",
            templateUrl: "views/dashboard.html",
            controller: "DashboardController",
            resolve: { auth: authGuard }
        })

        // ===== HỒ SƠ CÁ NHÂN =====
        .state("main.profile", {
            url: "/profile",
            templateUrl: "views/profile.html",
            controller: "ProfileController",
            resolve: { auth: authGuard }
        })

        // =====================================================
        // 🧩 ADMIN AREA
        // =====================================================
        .state("admin", {
            url: "/admin",
            abstract: true,
            template: "<ui-view></ui-view>",
            resolve: { auth: authGuard }
        })

        // 🔸 ADMIN: QUẢN LÝ TÀI KHOẢN NGƯỜI DÙNG
        .state("admin.userAccount", {
            url: "/user/account",
            templateUrl: "views/admin/account.html",
            controller: "AccountController",
            resolve: { auth: authGuard }
        })

        // 🔸 ADMIN: QUẢN LÝ VAI TRÒ & QUYỀN HẠN
        .state("admin.roleManage", {
            url: "/role/manage",
            templateUrl: "views/admin/role-manage.html",
            controller: "RoleManageController",
            resolve: { auth: authGuard }
        })

        // 🔸 ADMIN: PHÂN QUYỀN
        .state("admin.rolePermission", {
            url: "/role/permission",
            templateUrl: "views/admin/role-permission.html",
            controller: "RolePermissionController",
            resolve: { auth: authGuard }
        });

    /* ============================================================
       3️⃣ URL mặc định
    ============================================================ */
    $urlRouterProvider.otherwise("/login");
});

/* ============================================================
   🚀 CHẠY SAU KHI ỨNG DỤNG KHỞI ĐỘNG
============================================================ */
app.run(function ($transitions, $state, AuthService, $rootScope) {

    // 🔹 Điều hướng: nếu đã login mà vẫn vào /login thì tự sang dashboard
    $transitions.onStart({ to: "login" }, function () {
        if (AuthService.isAuthenticated()) {
            return $state.target("main.dashboard");
        }
    });

    // 🔹 Theo dõi trạng thái xác thực toàn cục
    $rootScope.isAuthenticated = AuthService.isAuthenticated();

    // 🔹 Khi logout thì cập nhật lại
    $rootScope.$on("auth:logout", function () {
        $rootScope.isAuthenticated = false;
    });

    $rootScope.$on("auth:login", function () {
        $rootScope.isAuthenticated = true;
    });
});
