// Student Sidebar Directive
app.directive('appSidebar', ['$location', 'AuthService', function($location, AuthService) {
    return {
        restrict: 'E',
        templateUrl: 'views/partials/sidebar.html',
        link: function(scope) {
            // Get current user
            scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Sinh viên' };
            
            // Student menu items
            scope.menuItems = [
                {
                    section: 'TỔNG QUAN',
                    items: [
                        { label: 'Dashboard', path: '/dashboard', icon: 'fas fa-home' }
                    ]
                },
                {
                    section: 'HỌC TẬP',
                    items: [
                        { label: 'Thời khóa biểu', path: '/timetable', icon: 'fas fa-calendar-alt' },
                        { label: 'Lịch học', path: '/schedule', icon: 'fas fa-calendar-week' },
                        { label: 'Bảng điểm', path: '/grades', icon: 'fas fa-chart-line' },
                        { label: 'Điểm danh', path: '/attendance', icon: 'fas fa-clipboard-check' }
                    ]
                },
                {
                    section: 'ĐĂNG KÝ',
                    items: [
                        { label: 'Đăng ký học phần', path: '/enrollment', icon: 'fas fa-edit' }
                    ]
                },
                {
                    section: 'CÁ NHÂN',
                    items: [
                        { label: 'Thông tin cá nhân', path: '/profile', icon: 'fas fa-user' }
                    ]
                }
            ];
            
            // Trạng thái mở/đóng cho từng section
            scope.openSections = {};
            
            // Build href
            scope.buildHref = function(path) {
                if (!path) return '#!';
                var normalized = String(path).replace(/\s+/g, '');
                if (normalized.charAt(0) !== '/') {
                    normalized = '/' + normalized;
                }
                normalized = normalized.replace(/\/+/g, '/');
                return '#!' + normalized;
            };
            
            // Toggle section
            scope.toggleSection = function(sectionIndex) {
                var willOpen = !scope.openSections[sectionIndex];
                Object.keys(scope.openSections).forEach(function(key) {
                    scope.openSections[key] = false;
                });
                scope.openSections[sectionIndex] = willOpen;
            };
            
            // Check if section is open
            scope.isSectionOpen = function(sectionIndex) {
                return !!scope.openSections[sectionIndex];
            };
            
            // Auto-expand section for current path
            function expandSectionForCurrentPath() {
                var currentPath = $location.path();
                if (!Array.isArray(scope.menuItems)) return;
                scope.menuItems.forEach(function(section, idx) {
                    var hasActive = (section.items || []).some(function(item) {
                        return currentPath === item.path || (item.path !== '/' && currentPath.indexOf(item.path) === 0);
                    });
                    scope.openSections[idx] = hasActive;
                });
            }
            expandSectionForCurrentPath();
            
            // Check if menu item is active
            scope.isActive = function(path) {
                var currentPath = $location.path();
                if (currentPath === path) {
                    return true;
                }
                if (path !== '/' && currentPath.indexOf(path) === 0) {
                    return true;
                }
                return false;
            };
            
            // Watch for route changes
            scope.$on('$routeChangeSuccess', function() {
                scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Sinh viên' };
                expandSectionForCurrentPath();
            });
        }
    };
}]);


