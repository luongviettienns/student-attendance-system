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

            // Trạng thái mở/đóng cho từng section
            scope.openSections = {};

            // Chuẩn hóa link hashbang, tránh // gây $location:badpath
            scope.buildHref = function(path) {
                if (!path) return '#!';
                var normalized = String(path).replace(/\s+/g, '');
                if (normalized.charAt(0) !== '/') {
                    normalized = '/' + normalized;
                }
                // Loại bỏ double slash nếu có
                normalized = normalized.replace(/\/+/g, '/');
                return '#!' + normalized;
            };

            // Toggle một section theo index
            scope.toggleSection = function(sectionIndex, event) {
                // Prevent any default behavior or navigation
                if (event) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                
                var willOpen = !scope.openSections[sectionIndex];
                // Đóng tất cả section khác
                Object.keys(scope.openSections).forEach(function(key) {
                    scope.openSections[key] = false;
                });
                // Mở section hiện tại nếu cần
                scope.openSections[sectionIndex] = willOpen;
            };

            // Kiểm tra section mở
            scope.isSectionOpen = function(sectionIndex) {
                return !!scope.openSections[sectionIndex];
            };

            // Tự động mở section chứa route hiện tại
            function expandSectionForCurrentPath() {
                var currentPath = $location.path();
                if (!Array.isArray(scope.menuSections)) return;
                scope.menuSections.forEach(function(section, idx) {
                    var hasActive = (section.items || []).some(function(item) {
                        return currentPath === item.path || (item.path !== '/' && currentPath.indexOf(item.path) === 0);
                    });
                    scope.openSections[idx] = hasActive;
                });
            }
            expandSectionForCurrentPath();
            
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
            
            // Navigate to path (explicit navigation)
            scope.navigateTo = function(path, event) {
                if (!path) {
                    if (event) event.preventDefault();
                    return;
                }
                
                // Prevent default link behavior if event is provided
                if (event) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                
                // Normalize path
                var normalized = String(path).replace(/\s+/g, '');
                if (normalized.charAt(0) !== '/') {
                    normalized = '/' + normalized;
                }
                normalized = normalized.replace(/\/+/g, '/');
                
                // Navigate using $location (will trigger digest automatically)
                $location.path(normalized);
            };
            
            // Listen for menu updates from API
            scope.$on('menu:updated', function(event, menuItems) {
                scope.menuSections = menuItems;
                expandSectionForCurrentPath();
            });
            
            // Listen for menu reload event (when permissions are updated)
            scope.$on('menu:reload', function() {
                RoleService.clearCache();
                RoleService.loadMenuItems().then(function(menuItems) {
                    scope.menuSections = menuItems;
                    expandSectionForCurrentPath();
                });
            });
            
            // Load menu from API on init
            RoleService.loadMenuItems().then(function(menuItems) {
                scope.menuSections = menuItems;
                expandSectionForCurrentPath();
            });
            
            // Watch for route changes
            scope.$on('$routeChangeSuccess', function() {
                // Update current user if needed
                scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Admin' };
                // Update menu items (use sync method to get latest)
                scope.menuSections = RoleService.getMenuItemsSync();
                // Sync trạng thái mở theo route
                expandSectionForCurrentPath();
            });
        }
    };
}]);

