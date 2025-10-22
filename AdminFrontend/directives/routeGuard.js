// Route Guard - Bảo vệ các route theo role
app.run(['$rootScope', '$location', 'AuthService', 'RoleService', 'ToastService', 
    function($rootScope, $location, AuthService, RoleService, ToastService) {
    
    // ✅ Các route PUBLIC (không cần login)
    var publicRoutes = ['/login', '/register', '/forgot-password'];
    
    // ✅ Lắng nghe sự kiện thay đổi route
    $rootScope.$on('$locationChangeStart', function(event, next, current) {
        var path = $location.path();
        
        // ✅ Cho phép truy cập public routes
        if (publicRoutes.indexOf(path) !== -1) {
            return;
        }
        
        // ✅ Kiểm tra đăng nhập
        if (!AuthService.isLoggedIn()) {
            event.preventDefault();
            $location.path('/login');
            ToastService.warning('Vui lòng đăng nhập để tiếp tục');
            return;
        }
        
        // ✅ Kiểm tra quyền truy cập route
        if (!RoleService.isRouteAllowed(path)) {
            event.preventDefault();
            
            var role = RoleService.getCurrentRole();
            var defaultRoute = getDefaultRouteForRole(role);
            
            $location.path(defaultRoute);
            ToastService.error('Bạn không có quyền truy cập trang này');
            return;
        }
    });
    
    /**
     * Get default route based on user role
     */
    function getDefaultRouteForRole(role) {
        var defaults = {
            'Admin': '/dashboard',
            'Lecturer': '/lecturer/dashboard',
            'Student': '/student/dashboard',
            'Advisor': '/advisor/dashboard'
        };
        return defaults[role] || '/dashboard';
    }
}]);

// ✅ Directive để kiểm tra permission trong template
app.directive('requirePermission', ['RoleService', function(RoleService) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var permission = attrs.requirePermission;
            
            // Hide element if user doesn't have permission
            if (!RoleService.hasPermission(permission)) {
                element.remove();
            }
        }
    };
}]);

// ✅ Directive để kiểm tra role trong template
app.directive('requireRole', ['RoleService', function(RoleService) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            var requiredRoles = attrs.requireRole.split(',');
            
            // Hide element if user doesn't have required role
            if (!RoleService.hasAnyRole(requiredRoles)) {
                element.remove();
            }
        }
    };
}]);

