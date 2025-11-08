// @ts-check
/* global angular */
'use strict';

// AngularJS Application Configuration
var app = angular.module('adminApp', ['ngRoute', 'ngAnimate']);

// Academic rules & thresholds (centralised to avoid scattering magic numbers)
app.constant('ACADEMIC_RULES', {
    defaultRequiredCredits: 120,
    passingScore: 5.0,
    excellentThreshold: 9.0,
    goodThreshold: 8.0,
    averageThreshold: 5.5
});

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
        
        // Attendance Management
        .when('/attendances', {
            templateUrl: 'views/attendances/list.html',
            controller: 'AttendanceController'
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
        .when('/lecturer/appeals', {
            templateUrl: 'views/lecturer/appeals.html',
            controller: 'LecturerGradeAppealController'
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
        .when('/advisor/students/:studentId', {
            templateUrl: 'views/advisor/student-detail.html',
            controller: 'AdvisorStudentController'
        })
        .when('/advisor/students', {
            templateUrl: 'views/advisor/students.html',
            controller: 'AdvisorStudentListController'
        })
        .when('/advisor/students/:studentId/progress', {
            templateUrl: 'views/advisor/student-progress.html',
            controller: 'AdvisorProgressController'
        })
        .when('/advisor/warnings', {
            templateUrl: 'views/advisor/warnings.html',
            controller: 'AdvisorWarningController'
        })
        .when('/advisor/appeals', {
            templateUrl: 'views/advisor/appeals.html',
            controller: 'AdvisorGradeAppealController'
        })
        .when('/advisor/grade-formula', {
            templateUrl: 'views/advisor/grade-formula.html',
            controller: 'AdvisorGradeFormulaConfigController'
        })
        .when('/advisor/enrollments', {
            templateUrl: 'views/advisor/enrollments.html',
            controller: 'AdvisorEnrollmentController'
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
        .when('/student/appeals', {
            templateUrl: 'views/student/appeals.html',
            controller: 'StudentGradeAppealController'
        })
        .when('/student/attendance', {
            templateUrl: 'views/student/attendance.html',
            controller: 'StudentAttendanceController'
        })
        .when('/student/profile', {
            templateUrl: 'views/student/profile.html',
            controller: 'StudentProfileController'
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
app.run(['$rootScope', '$location', 'AuthService', 'LoggerService', 'NotificationService', function($rootScope, $location, AuthService, LoggerService, NotificationService) {
    // Global logout function available in all views
    $rootScope.logout = function() {
        LoggerService.log('Logging out...');
        AuthService.logout();
        $location.path('/login');
    };
    
    // Load unread notification count on app start (if user is authenticated)
    $rootScope.$on('$routeChangeStart', function(event, next, current) {
        if (AuthService.isAuthenticated() && next && !next.publicAccess) {
            // Load unread count when navigating to authenticated pages
            NotificationService.loadUnreadCount();
        }
    });
    
    // Initial load if already authenticated
    if (AuthService.isAuthenticated()) {
        NotificationService.loadUnreadCount();
    }
    
    // Get current user for display in header
    $rootScope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    $rootScope.$on('$routeChangeStart', function(event, next) {
        if (!next.publicAccess && !AuthService.isAuthenticated()) {
            $location.path('/login');
        }
        
        // If authenticated and trying to access login, redirect based on role
        if (next && next.publicAccess && AuthService.isAuthenticated()) {
            var currentUser = AuthService.getCurrentUser();
            // Backend returns 'role' (lowercase) or 'Role' (capital), not 'roleName'
            var userRole = (currentUser && currentUser.role) || (currentUser && currentUser.Role) || (currentUser && currentUser.roleName) || 'Admin';
            
            // Normalize role
            if (userRole) {
                userRole = userRole.trim();
                var roleMap = {
                    'Cố vấn': 'Advisor',
                    'Giảng viên': 'Lecturer',
                    'Sinh viên': 'Student',
                    'Quản trị viên': 'Admin'
                };
                userRole = roleMap[userRole] || userRole;
            }
            
            // Redirect based on user role
            var defaultRoute = '/dashboard';
            if (userRole === 'Student') {
                defaultRoute = '/student/dashboard';
            } else if (userRole === 'Lecturer') {
                defaultRoute = '/lecturer/dashboard';
            } else if (userRole === 'Advisor') {
                defaultRoute = '/advisor/dashboard';
            }
            
            $location.path(defaultRoute);
        }
    });
}]);

// HTTP Interceptor for adding JWT token
app.factory('AuthInterceptor', ['$q', '$location', '$window', '$injector', function($q, $location, $window, $injector) {
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
                // Unauthorized - Clear tokens and redirect to login
                $window.localStorage.removeItem('auth_token');
                $window.localStorage.removeItem('user_info');
                $window.sessionStorage.removeItem('auth_token');
                $window.sessionStorage.removeItem('user_info');
                $location.path('/login');
                // Try to show toast if ToastService is available
                try {
                    var ToastService = $injector.get('ToastService');
                    ToastService.warning('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
                } catch (e) {
                    // ToastService not available, skip
                }
            } else if (rejection.status === 403) {
                // Forbidden - User doesn't have permission
                // Don't show error toast for 403, let the controller handle it
                // This prevents spam of error messages for admin-only features
                // Silent - no console output
            } else if (rejection.status === 404) {
                // Not Found - Resource doesn't exist
                // Don't show error toast, let the controller handle it
                // Silent - no console output
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

