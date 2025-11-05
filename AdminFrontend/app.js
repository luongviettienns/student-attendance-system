// AngularJS Application Configuration
var app = angular.module('adminApp', ['ngRoute', 'ngAnimate']);

// API Configuration (Microservices Pattern - All via Gateway)
app.constant('API_CONFIG', {
    BASE_URL: 'http://localhost:5227/api-edu',        // Direct to Admin API (for testing)
    // BASE_URL: 'https://localhost:7033/api-edu',    // API Gateway URL (production)
    GATEWAY_URL: 'https://localhost:7033'             // Gateway URL (all requests go through here)
    // ✅ Avatars cũng load qua Gateway: https://localhost:7033/avatars/...
    // ✅ Gateway sẽ proxy đến Admin API
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
        
        // User Management
        .when('/users', {
            templateUrl: 'views/users/list.html',
            controller: 'UserController'
        })
        .when('/users/create', {
            templateUrl: 'views/users/form.html',
            controller: 'UserController'
        })
        .when('/users/edit/:id', {
            templateUrl: 'views/users/form.html',
            controller: 'UserController'
        })
        
        // Role Management
        .when('/roles', {
            templateUrl: 'views/roles/list.html',
            controller: 'RoleController'
        })
        
        // Organization Management - TÍCH HỢP TOÀN BỘ (Khoa, Bộ môn, Ngành, Môn học)
        .when('/organization', {
            templateUrl: 'views/organization/index.html',
            controller: 'OrganizationController'
        })
        
        // Legacy routes - redirect to organization page
        .when('/faculties', {
            redirectTo: '/organization'
        })
        .when('/departments', {
            redirectTo: '/organization'
        })
        .when('/majors', {
            redirectTo: '/organization'
        })
        .when('/subjects', {
            redirectTo: '/organization'
        })
        
        // Academic Year Management
        .when('/academic-years', {
            templateUrl: 'views/academic-years/list.html',
            controller: 'AcademicYearController'
        })
        .when('/academic-years/create', {
            templateUrl: 'views/academic-years/form.html',
            controller: 'AcademicYearController'
        })
        .when('/academic-years/edit/:id', {
            templateUrl: 'views/academic-years/form.html',
            controller: 'AcademicYearController'
        })
        
        // School Year Management
        .when('/school-years', {
            templateUrl: 'views/school-years/list.html',
            controller: 'SchoolYearController'
        })
        .when('/school-years/create', {
            templateUrl: 'views/school-years/form.html',
            controller: 'SchoolYearController'
        })
        .when('/school-years/edit/:id', {
            templateUrl: 'views/school-years/form.html',
            controller: 'SchoolYearController'
        })
        
        // Student Management
        .when('/students', {
            templateUrl: 'views/students/list.html',
            controller: 'StudentController'
        })
        .when('/students/create', {
            templateUrl: 'views/students/form.html',
            controller: 'StudentController'
        })
        .when('/students/edit/:id', {
            templateUrl: 'views/students/form.html',
            controller: 'StudentController'
        })
        
        // Lecturer Management (Kèm phân môn)
        .when('/lecturers', {
            templateUrl: 'views/lecturers/manage.html',
            controller: 'LecturerManagementController'
        })
        
        // Class Management
        .when('/classes', {
            templateUrl: 'views/classes/list.html',
            controller: 'ClassController'
        })
        
        // Lecturer Portal
        .when('/lecturer/dashboard', {
            templateUrl: 'views/lecturer/dashboard.html',
            controller: 'LecturerDashboardController'
        })
        .when('/lecturer/attendance', {
            templateUrl: 'views/lecturer/attendance.html',
            controller: 'LecturerAttendanceController'
        })
        .when('/lecturer/grades', {
            templateUrl: 'views/lecturer/grades.html',
            controller: 'LecturerGradesController'
        })
        .when('/lecturer/timetable', {
            templateUrl: 'views/lecturer/timetable.html',
            controller: 'LecturerTimetableController'
        })
        
        // Advisor Portal
        .when('/advisor/dashboard', {
            templateUrl: 'views/advisor/dashboard.html',
            controller: 'AdvisorDashboardController'
        })
        
        // Student Portal
        .when('/student/dashboard', {
            templateUrl: 'views/student/dashboard.html',
            controller: 'StudentDashboardController'
        })
        .when('/student/timetable', {
            templateUrl: 'views/student/timetable.html',
            controller: 'StudentTimetableController'
        })
        .when('/student/schedule', {
            templateUrl: 'views/student/schedule.html',
            controller: 'StudentScheduleController'
        })
        .when('/student/grades', {
            templateUrl: 'views/student/grades.html',
            controller: 'StudentGradesController'
        })
        
        // =============================================
        // 🔹 PHASE 2: ENROLLMENT SYSTEM
        // =============================================
        
        // Administrative Classes
        .when('/admin-classes', {
            templateUrl: 'views/admin-classes/list.html',
            controller: 'AdministrativeClassController'
        })
        
        // Registration Periods
        .when('/registration-periods', {
            templateUrl: 'views/registration-periods/manage.html',
            controller: 'RegistrationPeriodController'
        })
        
        // Enrollments - Student
        .when('/student/enrollments', {
            templateUrl: 'views/enrollments/student-register.html',
            controller: 'EnrollmentController'
        })
        
        // Enrollments - Admin
        .when('/enrollments', {
            templateUrl: 'views/enrollments/admin-manage.html',
            controller: 'EnrollmentController'
        })
        
        // Subject Prerequisites
        .when('/subject-prerequisites', {
            templateUrl: 'views/subject-prerequisites/manage.html',
            controller: 'SubjectPrerequisiteController'
        })
        
        // System Management
        .when('/audit-logs', {
            templateUrl: 'views/audit-logs/list.html',
            controller: 'AuditLogController'
        })
        .when('/notifications', {
            templateUrl: 'views/notifications/list.html',
            controller: 'NotificationController'
        })
        
        // Admin Timetable Management
        .when('/admin/timetable', {
            templateUrl: 'views/admin/timetable.html',
            controller: 'AdminTimetableController'
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

