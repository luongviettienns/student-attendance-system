// Role-based Access Control Service
app.service('RoleService', ['AuthService', function(AuthService) {
    
    // Define role-based permissions
    var ROLE_PERMISSIONS = {
        'Admin': {
            canManageUsers: true,
            canManageOrganization: true,
            canManageStudents: true,
            canManageLecturers: true,
            canManageSubjects: true,
            canManageClasses: true,
            canViewAuditLogs: true,
            canManageRoles: true,
            canViewAllData: true
        },
        'Lecturer': {
            canManageUsers: false,
            canManageOrganization: false,
            canManageStudents: false,
            canManageLecturers: false,
            canManageSubjects: false,
            canManageClasses: true,      // Lecturer có thể quản lý lớp của mình
            canViewAuditLogs: false,
            canManageRoles: false,
            canViewAllData: false,
            canTakeAttendance: true,      // Điểm danh
            canEnterGrades: true          // Nhập điểm
        },
        'Student': {
            canManageUsers: false,
            canManageOrganization: false,
            canManageStudents: false,
            canManageLecturers: false,
            canManageSubjects: false,
            canManageClasses: false,
            canViewAuditLogs: false,
            canManageRoles: false,
            canViewAllData: false,
            canViewOwnSchedule: true,     // Xem lịch của mình
            canViewOwnGrades: true        // Xem điểm của mình
        },
        'Advisor': {
            canManageUsers: false,
            canManageOrganization: false,
            canManageStudents: true,      // Cố vấn có thể quản lý sinh viên
            canManageLecturers: false,
            canManageSubjects: false,
            canManageClasses: false,
            canViewAuditLogs: false,
            canManageRoles: false,
            canViewAllData: false,
            canViewAdvisees: true         // Xem sinh viên được phụ trách
        }
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
        var role = this.getCurrentRole();
        if (!role || !ROLE_PERMISSIONS[role]) {
            return false;
        }
        return ROLE_PERMISSIONS[role][permission] === true;
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
                '/students', '/lecturers',
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

