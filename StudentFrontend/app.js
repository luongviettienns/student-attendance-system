// AngularJS Application Configuration for Student Portal
var app = angular.module('studentApp', ['ngRoute', 'ngAnimate']);

// API Configuration (Microservices Pattern - All via Gateway)
app.constant('API_CONFIG', {
    BASE_URL: 'http://localhost:5227/api-edu',        // Direct to Admin API (for testing)
    // BASE_URL: 'https://localhost:7033/api-edu',    // API Gateway URL (production)
    GATEWAY_URL: 'https://localhost:7033'             // Gateway URL (all requests go through here)
});

// Route Configuration
app.config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    // Đảm bảo sử dụng hashbang kiểu #! để điều hướng đúng
    $locationProvider.hashPrefix('!');
    $routeProvider
        // Login
        .when('/login', {
            templateUrl: 'views/login.html',
            controller: 'LoginController',
            publicAccess: true
        })
        .when('/forgot-password', {
            templateUrl: 'views/auth/forgot-password.html',
            controller: 'ForgotPasswordController',
            publicAccess: true
        })
        .when('/reset-password/:token', {
            templateUrl: 'views/auth/reset-password.html',
            controller: 'ResetPasswordController',
            publicAccess: true
        })
        
        // Dashboard
        .when('/dashboard', {
            templateUrl: 'views/dashboard.html',
            controller: 'DashboardController'
        })
        
        // Timetable
        .when('/timetable', {
            templateUrl: 'views/timetable.html',
            controller: 'TimetableController'
        })
        
        // Schedule
        .when('/schedule', {
            templateUrl: 'views/schedule.html',
            controller: 'ScheduleController'
        })
        
        // Grades
        .when('/grades', {
            templateUrl: 'views/grades.html',
            controller: 'GradesController'
        })
        
        // Enrollment
        .when('/enrollment', {
            templateUrl: 'views/enrollment.html',
            controller: 'EnrollmentController'
        })
        
        // Attendance
        .when('/attendance', {
            templateUrl: 'views/attendance.html',
            controller: 'AttendanceController'
        })
        
        // Profile
        .when('/profile', {
            templateUrl: 'views/profile.html',
            controller: 'ProfileController'
        })
        
        // Default route
        .otherwise({
            redirectTo: '/login'
        });
}]);

// Run block - Check authentication and add global logout
app.run(['$rootScope', '$location', 'AuthService', 'LoggerService', function($rootScope, $location, AuthService, LoggerService) {
    // Global logout function available in all views
    $rootScope.logout = function() {
        LoggerService.log('Logging out...');
        AuthService.logout();
        $location.path('/login');
    };
    
    // Get current user for display in header
    $rootScope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    $rootScope.$on('$routeChangeStart', function(event, next) {
        if (!next.publicAccess && !AuthService.isAuthenticated()) {
            $location.path('/login');
        }
        
        // If authenticated and trying to access login, redirect to dashboard
        if (next.publicAccess && AuthService.isAuthenticated()) {
            $location.path('/dashboard');
        }
    });
}]);

// HTTP Interceptor for adding JWT token
app.factory('AuthInterceptor', ['$q', '$location', '$window', function($q, $location, $window) {
    return {
        request: function(config) {
            // Check both localStorage and sessionStorage for token
            var token = $window.localStorage.getItem('auth_token') || 
                       $window.sessionStorage.getItem('auth_token');
            if (token) {
                config.headers.Authorization = 'Bearer ' + token;
            }
            return config;
        },
        responseError: function(rejection) {
            if (rejection.status === 401) {
                // Clear tokens from both storages and redirect to login
                $window.localStorage.removeItem('auth_token');
                $window.localStorage.removeItem('user_info');
                $window.sessionStorage.removeItem('auth_token');
                $window.sessionStorage.removeItem('user_info');
                $location.path('/login');
            }
            return $q.reject(rejection);
        }
    };
}]);

app.config(['$httpProvider', function($httpProvider) {
    $httpProvider.interceptors.push('AuthInterceptor');
}]);

// 🔧 FIX: Close all modals when route changes
app.run(['$rootScope', function($rootScope) {
    $rootScope.$on('$routeChangeStart', function() {
        // Close all modals when navigating to a new page
        if (typeof ModalUtils !== 'undefined') {
            ModalUtils.closeAll();
        }
    });
}]);


