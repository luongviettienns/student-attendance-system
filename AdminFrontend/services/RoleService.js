// Role-based Access Control Service
app.service('RoleService', ['AuthService', '$http', '$rootScope', 'API_CONFIG', function(AuthService, $http, $rootScope, API_CONFIG) {
    
    // Cache for permissions loaded from API
    var cachedPermissions = null;
    var permissionCodesCache = [];
    
    // Listen for logout event to clear cache
    var self = this;
    $rootScope.$on('user:logout', function() {
        self.clearCache();
    });
    
    // Permission code mapping to frontend permission names
    // Map backend permission codes to frontend permission flags
    var PERMISSION_MAP = {
        // User Management (Quản lý người dùng)
        'VIEW_USERS': 'canManageUsers',
        'CREATE_USERS': 'canManageUsers',
        'EDIT_USERS': 'canManageUsers',
        'DELETE_USERS': 'canManageUsers',
        'TOGGLE_USER_STATUS': 'canManageUsers',
        'RESET_PASSWORD': 'canManageUsers',
        
        // Role & Permission Management (Quản lý vai trò & phân quyền)
        'VIEW_ROLES': 'canManageRoles',
        'CREATE_ROLES': 'canManageRoles',
        'EDIT_ROLES': 'canManageRoles',
        'DELETE_ROLES': 'canManageRoles',
        'VIEW_PERMISSIONS': 'canManageRoles',
        'MANAGE_PERMISSIONS': 'canManageRoles',
        
        // Student Management (Quản lý sinh viên)
        'VIEW_STUDENTS': 'canManageStudents',
        'VIEW_STUDENT_DETAIL': 'canManageStudents',
        'CREATE_STUDENTS': 'canManageStudents',
        'EDIT_STUDENTS': 'canManageStudents',
        'DELETE_STUDENTS': 'canManageStudents',
        'IMPORT_STUDENTS': 'canManageStudents',
        'EXPORT_STUDENTS': 'canExportStudents',
        
        // Lecturer Management (Quản lý giảng viên)
        'VIEW_LECTURERS': 'canManageLecturers',
        'VIEW_LECTURER_DETAIL': 'canManageLecturers',
        'CREATE_LECTURERS': 'canManageLecturers',
        'EDIT_LECTURERS': 'canManageLecturers',
        'DELETE_LECTURERS': 'canManageLecturers',
        'ASSIGN_LECTURER_SUBJECTS': 'canManageLecturers',
        
        // Organization Management (Quản lý tổ chức)
        'VIEW_ORGANIZATION': 'canManageOrganization',
        'MANAGE_FACULTIES': 'canManageOrganization',
        'MANAGE_DEPARTMENTS': 'canManageOrganization',
        'MANAGE_MAJORS': 'canManageOrganization',
        
        // Subject Management (Quản lý môn học)
        'VIEW_SUBJECTS': 'canManageSubjects',
        'CREATE_SUBJECTS': 'canManageSubjects',
        'EDIT_SUBJECTS': 'canManageSubjects',
        'DELETE_SUBJECTS': 'canManageSubjects',
        
        // Class Management (Quản lý lớp học)
        'VIEW_ALL_CLASSES': 'canManageClasses',
        'VIEW_OWN_CLASSES': 'canViewOwnClasses',
        'CREATE_CLASSES': 'canManageClasses',
        'EDIT_CLASSES': 'canManageClasses',
        'DELETE_CLASSES': 'canManageClasses',
        'MANAGE_CLASS_ENROLLMENT': 'canManageClasses',
        
        // Schedule Management (Quản lý lịch học)
        'VIEW_ALL_SCHEDULES': 'canManageSchedules',
        'VIEW_OWN_SCHEDULE': 'canViewOwnSchedule',
        'MANAGE_SCHEDULES': 'canManageSchedules',
        'EXPORT_SCHEDULES': 'canExportSchedules',
        
        // Attendance Management (Điểm danh)
        'TAKE_ATTENDANCE': 'canTakeAttendance',
        'VIEW_ALL_ATTENDANCE': 'canViewAllAttendance',
        'VIEW_OWN_ATTENDANCE': 'canViewOwnAttendance',
        'EDIT_ATTENDANCE': 'canEditAttendance',
        'EXPORT_ATTENDANCE': 'canExportAttendance',
        
        // Grade Management (Quản lý điểm số)
        'ENTER_GRADES': 'canEnterGrades',
        'VIEW_ALL_GRADES': 'canViewAllGrades',
        'VIEW_OWN_GRADES': 'canViewOwnGrades',
        'EDIT_GRADES': 'canEditGrades',
        'APPROVE_GRADES': 'canApproveGrades',
        'EXPORT_GRADES': 'canExportGrades',
        
        // Academic Year Management (Quản lý niên khóa)
        'VIEW_ACADEMIC_YEARS': 'canViewAcademicYears',
        'CREATE_ACADEMIC_YEARS': 'canManageAcademicYears',
        'EDIT_ACADEMIC_YEARS': 'canManageAcademicYears',
        'DELETE_ACADEMIC_YEARS': 'canManageAcademicYears',
        'SET_ACTIVE_ACADEMIC_YEAR': 'canManageAcademicYears',
        
        // Academic Advisor (Cố vấn học tập)
        'VIEW_ADVISEES': 'canViewAdvisees',
        'VIEW_ADVISEE_GRADES': 'canViewAdvisees',
        'VIEW_ADVISEE_ATTENDANCE': 'canViewAdvisees',
        'MANAGE_ADVISEES': 'canManageAdvisees',
        
        // Reports & Statistics (Báo cáo & thống kê)
        'VIEW_REPORTS': 'canViewReports',
        'EXPORT_REPORTS': 'canExportReports',
        'VIEW_DASHBOARD_STATS': 'canViewDashboard',
        
        // Notifications (Thông báo)
        'VIEW_NOTIFICATIONS': 'canViewNotifications',
        'CREATE_NOTIFICATIONS': 'canCreateNotifications',
        'MANAGE_NOTIFICATIONS': 'canManageNotifications',
        
        // System Management (Hệ thống)
        'VIEW_AUDIT_LOGS': 'canViewAuditLogs',
        'EXPORT_AUDIT_LOGS': 'canExportAuditLogs',
        'MANAGE_SYSTEM_SETTINGS': 'canManageSystem',
        'BACKUP_RESTORE': 'canManageSystem',
        'VIEW_SYSTEM_INFO': 'canViewSystemInfo'
    };
    
    // Fallback permissions (used when API fails)
    var FALLBACK_PERMISSIONS = {
        'Admin': {
            // All permissions - Admin có toàn quyền
            canManageUsers: true,
            canManageRoles: true,
            canManageStudents: true,
            canManageLecturers: true,
            canManageOrganization: true,
            canManageSubjects: true,
            canManageClasses: true,
            canManageSchedules: true,
            canManageAcademicYears: true,
            canTakeAttendance: true,
            canViewAllAttendance: true,
            canEditAttendance: true,
            canEnterGrades: true,
            canViewAllGrades: true,
            canEditGrades: true,
            canApproveGrades: true,
            canViewReports: true,
            canExportReports: true,
            canViewAuditLogs: true,
            canManageSystem: true,
            canViewDashboard: true,
            canManageNotifications: true,
            canViewAllData: true
        },
        'Lecturer': {
            // Giảng viên - quyền giảng dạy
            canManageUsers: false,
            canManageRoles: false,
            canManageStudents: false, // Chỉ xem sinh viên trong lớp mình dạy
            canManageLecturers: false,
            canManageOrganization: false,
            canManageSubjects: false,
            canManageClasses: false, // Chỉ quản lý lớp mình dạy
            canViewOwnClasses: true,
            canManageSchedules: false,
            canViewOwnSchedule: true,
            canManageAcademicYears: false,
            canViewAcademicYears: true,
            canTakeAttendance: true,
            canViewAllAttendance: false, // Chỉ xem điểm danh lớp mình dạy
            canEditAttendance: true,
            canExportAttendance: true,
            canEnterGrades: true,
            canViewAllGrades: false, // Chỉ xem điểm lớp mình dạy
            canEditGrades: true,
            canExportGrades: true,
            canViewReports: true,
            canExportReports: true,
            canViewDashboard: true,
            canCreateNotifications: true,
            canViewNotifications: true
        },
        'Student': {
            // Sinh viên - chỉ xem thông tin của mình
            canManageUsers: false,
            canManageRoles: false,
            canManageStudents: false,
            canManageLecturers: false,
            canManageOrganization: false,
            canManageSubjects: false,
            canManageClasses: false,
            canViewOwnClasses: true,
            canManageSchedules: false,
            canViewOwnSchedule: true,
            canExportSchedules: true,
            canManageAcademicYears: false,
            canViewAcademicYears: true,
            canTakeAttendance: false,
            canViewOwnAttendance: true,
            canEnterGrades: false,
            canViewOwnGrades: true,
            canViewDashboard: true,
            canViewNotifications: true
        },
        'Advisor': {
            // Cố vấn - quản lý sinh viên được phụ trách
            canManageUsers: false,
            canManageRoles: false,
            canManageStudents: true, // Chỉ sinh viên được phụ trách
            canManageLecturers: false,
            canManageOrganization: false,
            canManageSubjects: false,
            canManageClasses: false,
            canManageSchedules: false,
            canManageAcademicYears: false,
            canViewAcademicYears: true,
            canTakeAttendance: false,
            canEnterGrades: false,
            canViewAdvisees: true,
            canManageAdvisees: true,
            canViewReports: true,
            canExportReports: true,
            canViewDashboard: true,
            canCreateNotifications: true,
            canViewNotifications: true
        }
    };
    
    /**
     * Load permissions from API
     */
    this.loadPermissions = function() {
        var self = this;
        var role = self.getCurrentRole();
        
        if (!role) {
            return Promise.reject('No role found');
        }
        
        // Return cached if available
        if (cachedPermissions) {
            return Promise.resolve(cachedPermissions);
        }
        
        // Load from API
        return $http.get(API_CONFIG.BASE_URL + '/menu/permissions')
            .then(function(response) {
                permissionCodesCache = response.data.permissions || [];
                
                // Build permissions object from permission codes
                var permissions = {};
                permissionCodesCache.forEach(function(code) {
                    var frontendPermission = PERMISSION_MAP[code];
                    if (frontendPermission) {
                        permissions[frontendPermission] = true;
                    }
                });
                
                cachedPermissions = permissions;
                return permissions;
            })
            .catch(function(error) {
                console.error('Failed to load permissions from API:', error);
                // Fallback to hard-coded permissions
                cachedPermissions = FALLBACK_PERMISSIONS[role] || {};
                return cachedPermissions;
            });
    };
    
    /**
     * Get current user role
     */
    this.getCurrentRole = function() {
        var user = AuthService.getCurrentUser();
        return user ? user.role : null;
    };
    
    /**
     * Check if user has a specific permission
     */
    this.hasPermission = function(permission) {
        // Use cached permissions if available
        if (cachedPermissions) {
            return cachedPermissions[permission] === true;
        }
        
        // Fallback to hard-coded permissions
        var role = this.getCurrentRole();
        if (!role || !FALLBACK_PERMISSIONS[role]) {
            return false;
        }
        return FALLBACK_PERMISSIONS[role][permission] === true;
    };
    
    /**
     * Check if user has specific role
     */
    this.hasRole = function(role) {
        return this.getCurrentRole() === role;
    };
    
    /**
     * Check if user has any of the specified roles
     */
    this.hasAnyRole = function(roles) {
        var currentRole = this.getCurrentRole();
        return roles.indexOf(currentRole) !== -1;
    };
    
    /**
     * Get allowed routes for current user role
     */
    this.getAllowedRoutes = function() {
        var role = this.getCurrentRole();
        
        var routeMap = {
            'Admin': [
                '/dashboard',
                '/users', '/roles',
                '/faculties', '/departments', '/majors', '/subjects',
                '/students', '/lecturers', '/classes',
                '/academic-years',
                '/audit-logs',
                '/notifications',
                '/organization'
            ],
            'Lecturer': [
                '/dashboard',
                '/lecturer/attendance',
                '/lecturer/grades',
                '/lecturer/dashboard',
                '/notifications'
            ],
            'Student': [
                '/dashboard',
                '/student/schedule',
                '/student/grades',
                '/student/dashboard',
                '/notifications'
            ],
            'Advisor': [
                '/dashboard',
                '/advisor/dashboard',
                '/students',
                '/notifications'
            ]
        };
        
        return routeMap[role] || [];
    };
    
    /**
     * Check if route is allowed for current user
     */
    this.isRouteAllowed = function(path) {
        var allowedRoutes = this.getAllowedRoutes();
        
        // Check exact match
        if (allowedRoutes.indexOf(path) !== -1) {
            return true;
        }
        
        // Check if path starts with any allowed route (for sub-routes)
        for (var i = 0; i < allowedRoutes.length; i++) {
            if (path.indexOf(allowedRoutes[i]) === 0) {
                return true;
            }
        }
        
        return false;
    };
    
    /**
     * Clear cached permissions (useful on logout)
     */
    this.clearCache = function() {
        cachedPermissions = null;
        permissionCodesCache = [];
    };
    
    /**
     * Get menu items for current user role
     */
    this.getMenuItems = function() {
        var role = this.getCurrentRole();
        
        var menuMap = {
            'Admin': [
                { section: 'TỔNG QUAN', items: [
                    { path: '/dashboard', icon: 'fas fa-tachometer-alt', label: 'Dashboard' }
                ]},
                { section: 'QUẢN LÝ NGƯỜI DÙNG', items: [
                    { path: '/users', icon: 'fas fa-users', label: 'Tài khoản' },
                    { path: '/roles', icon: 'fas fa-shield-alt', label: 'Vai trò & quyền' }
                ]},
                { section: 'QUẢN LÝ TỔ CHỨC', items: [
                    { path: '/organization', icon: 'fas fa-sitemap', label: 'Tổ chức' }
                ]},
                { section: 'QUẢN LÝ ĐÀO TẠO', items: [
                    { path: '/students', icon: 'fas fa-user-graduate', label: 'Sinh viên' },
                    { path: '/lecturers', icon: 'fas fa-chalkboard-teacher', label: 'Giảng viên' },
                    { path: '/classes', icon: 'fas fa-chalkboard', label: 'Lớp học' },
                    { path: '/academic-years', icon: 'fas fa-calendar-alt', label: 'Niên khóa' }
                ]},
                { section: 'HỆ THỐNG', items: [
                    { path: '/audit-logs', icon: 'fas fa-history', label: 'Nhật ký hệ thống' },
                    { path: '/notifications', icon: 'fas fa-bell', label: 'Thông báo' }
                ]}
            ],
            'Lecturer': [
                { section: 'TỔNG QUAN', items: [
                    { path: '/lecturer/dashboard', icon: 'fas fa-tachometer-alt', label: 'Dashboard' }
                ]},
                { section: 'GIẢNG DẠY', items: [
                    { path: '/lecturer/attendance', icon: 'fas fa-check-square', label: 'Điểm danh' },
                    { path: '/lecturer/grades', icon: 'fas fa-graduation-cap', label: 'Nhập điểm' }
                ]},
                { section: 'HỆ THỐNG', items: [
                    { path: '/notifications', icon: 'fas fa-bell', label: 'Thông báo' }
                ]}
            ],
            'Student': [
                { section: 'TỔNG QUAN', items: [
                    { path: '/student/dashboard', icon: 'fas fa-tachometer-alt', label: 'Dashboard' }
                ]},
                { section: 'HỌC TẬP', items: [
                    { path: '/student/schedule', icon: 'fas fa-calendar', label: 'Lịch học' },
                    { path: '/student/grades', icon: 'fas fa-graduation-cap', label: 'Kết quả học tập' }
                ]},
                { section: 'HỆ THỐNG', items: [
                    { path: '/notifications', icon: 'fas fa-bell', label: 'Thông báo' }
                ]}
            ],
            'Advisor': [
                { section: 'TỔNG QUAN', items: [
                    { path: '/advisor/dashboard', icon: 'fas fa-tachometer-alt', label: 'Dashboard' }
                ]},
                { section: 'CỐ VẤN', items: [
                    { path: '/students', icon: 'fas fa-user-graduate', label: 'Sinh viên' }
                ]},
                { section: 'HỆ THỐNG', items: [
                    { path: '/notifications', icon: 'fas fa-bell', label: 'Thông báo' }
                ]}
            ]
        };
        
        return menuMap[role] || [];
    };
}]);

