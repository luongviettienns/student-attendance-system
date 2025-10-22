// Sidebar Directive - Include sidebar vào tất cả views
app.directive('appSidebar', ['$location', 'AuthService', 'RoleService', function($location, AuthService, RoleService) {
    return {
        restrict: 'E',
        templateUrl: 'views/partials/sidebar.html',
        link: function(scope) {
            // Get current user
            scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Admin' };
            
            // ✅ Get menu items based on user role
            scope.menuSections = RoleService.getMenuItems();
            
            // ✅ Check if user has permission
            scope.hasPermission = function(permission) {
                return RoleService.hasPermission(permission);
            };
            
            // ✅ Check if user has role
            scope.hasRole = function(role) {
                return RoleService.hasRole(role);
            };
            
            // Check if menu item is active
            scope.isActive = function(path) {
                var currentPath = $location.path();
                
                // Exact match
                if (currentPath === path) {
                    return true;
                }
                
                // Starts with (for sub-routes like /users/create, /users/edit/123)
                if (path !== '/' && currentPath.indexOf(path) === 0) {
                    return true;
                }
                
                return false;
            };
            
            // Watch for route changes
            scope.$on('$routeChangeSuccess', function() {
                // Update current user if needed
                scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Admin' };
                // Update menu items
                scope.menuSections = RoleService.getMenuItems();
            });
        }
    };
}]);

