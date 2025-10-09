var app = angular.module("eduApp", ["ui.router", "ngFileUpload"]);

app.config(function($stateProvider, $urlRouterProvider, $httpProvider) {

    // Hàm bảo vệ route
    function authGuard(AuthService, $state, $q) {
        if (!AuthService.isAuthenticated()) {
            $state.go("login");
            return $q.reject("Not Authenticated");
        }
        return true;
    }

    $stateProvider
        .state("login", {
            url: "/login",
            templateUrl: "views/login.html",
            controller: "LoginController"
        })
        .state("main", {
            url: "/main",
            templateUrl: "views/main.html",
            controller: "MainController",
            resolve: { auth: authGuard }
        })
        .state("main.dashboard", {
            url: "/dashboard",
            templateUrl: "views/dashboard.html",
            controller: "DashboardController",
            resolve: { auth: authGuard }
        })
        .state("main.classes", {
            url: "/classes",
            templateUrl: "views/classes.html",
            controller: "ClassesController",
            resolve: { auth: authGuard }
        })
        .state("main.userManagement", {
    url: "/user-management",
    templateUrl: "views/admin/user-management.html",
    controller: "UserManagementController",
    resolve: { auth: authGuard }
})

        .state("main.profile", {
            url: "/profile",
            templateUrl: "views/profile-student.html",
            controller: "ProfileController",
            resolve: { auth: authGuard }
        });

    // URL mặc định
    $urlRouterProvider.otherwise("/login");

    // Interceptor gắn token + xử lý 401
    $httpProvider.interceptors.push("AuthInterceptor");
});

app.run(function($transitions, $state, AuthService) {
    $transitions.onStart({ to: "login" }, function() {
        if (AuthService.isAuthenticated()) {
            return $state.target("main.dashboard");
        }
    });
});
