// Notification Controller
app.controller('NotificationController', ['$scope', '$location', 'NotificationService', 'PaginationService', 'AuthService', 'AvatarService',
    function($scope, $location, NotificationService, PaginationService, AuthService, AvatarService) {
    
    $scope.notifications = [];
    $scope.displayedNotifications = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Get current user for header
    $scope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    // Logout function
    $scope.logout = function() {
        AuthService.logout(); // Will auto-redirect to login
    };
    
    // Pagination
    $scope.pagination = PaginationService.init(20);
    
    // Filters
    $scope.filters = {
        isRead: '',
        type: ''
    };
    
    // Load notifications
    $scope.loadNotifications = function() {
        $scope.loading = true;
        NotificationService.getAll()
            .then(function(response) {
                $scope.notifications = response.data;
                $scope.applyFiltersAndSort();
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông báo';
                $scope.loading = false;
            });
    };
    
    // Apply filters and sorting
    $scope.applyFiltersAndSort = function() {
        var filtered = $scope.notifications;
        
        // Apply search
        if ($scope.pagination.searchTerm) {
            var searchLower = $scope.pagination.searchTerm.toLowerCase();
            filtered = filtered.filter(function(notif) {
                return (notif.title && notif.title.toLowerCase().includes(searchLower)) ||
                       (notif.message && notif.message.toLowerCase().includes(searchLower));
            });
        }
        
        // Apply filters
        if ($scope.filters.isRead !== '') {
            var isRead = $scope.filters.isRead === 'true';
            filtered = filtered.filter(function(notif) {
                return notif.isRead === isRead;
            });
        }
        
        if ($scope.filters.type) {
            filtered = filtered.filter(function(notif) {
                return notif.type === $scope.filters.type;
            });
        }
        
        // Apply sorting (default by createdAt DESC)
        if (!$scope.pagination.sortField) {
            $scope.pagination.sortField = 'createdAt';
            $scope.pagination.sortDirection = 'desc';
        }
        
        filtered.sort(function(a, b) {
            var aVal = a[$scope.pagination.sortField] || '';
            var bVal = b[$scope.pagination.sortField] || '';
            
            if (aVal < bVal) return $scope.pagination.sortDirection === 'asc' ? -1 : 1;
            if (aVal > bVal) return $scope.pagination.sortDirection === 'asc' ? 1 : -1;
            return 0;
        });
        
        // Update pagination
        $scope.pagination.totalItems = filtered.length;
        $scope.pagination = PaginationService.calculate($scope.pagination);
        
        // Apply pagination
        var start = ($scope.pagination.currentPage - 1) * $scope.pagination.pageSize;
        var end = start + parseInt($scope.pagination.pageSize);
        $scope.displayedNotifications = filtered.slice(start, end);
    };
    
    // Event handlers
    $scope.handleSearch = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    $scope.handleSort = function() {
        $scope.applyFiltersAndSort();
    };
    
    $scope.handlePageChange = function() {
        $scope.applyFiltersAndSort();
    };
    
    $scope.handleFilterChange = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    $scope.resetFilters = function() {
        $scope.pagination.searchTerm = '';
        $scope.filters = {
            isRead: '',
            type: ''
        };
        $scope.handleFilterChange();
    };
    
    // Mark as read
    $scope.markAsRead = function(notificationId) {
        NotificationService.markAsRead(notificationId)
            .then(function() {
                // Update local data
                var notif = $scope.notifications.find(function(n) {
                    return n.id === notificationId;
                });
                if (notif) {
                    notif.isRead = true;
                }
                $scope.applyFiltersAndSort();
            })
            .catch(function(error) {
                $scope.error = 'Không thể đánh dấu đã đọc';
            });
    };
    
    // Mark all as read
    $scope.markAllAsRead = function() {
        NotificationService.markAllAsRead()
            .then(function() {
                $scope.notifications.forEach(function(notif) {
                    notif.isRead = true;
                });
                $scope.applyFiltersAndSort();
                $scope.success = 'Đã đánh dấu tất cả là đã đọc';
            })
            .catch(function(error) {
                $scope.error = 'Không thể đánh dấu tất cả';
            });
    };
    
    // Delete notification
    $scope.deleteNotification = function(notificationId) {
        if (!confirm('Bạn có chắc chắn muốn xóa thông báo này?')) {
            return;
        }
        
        NotificationService.deleteNotification(notificationId)
            .then(function() {
                $scope.notifications = $scope.notifications.filter(function(n) {
                    return n.id !== notificationId;
                });
                $scope.applyFiltersAndSort();
                $scope.success = 'Xóa thông báo thành công';
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa thông báo';
            });
    };
    
    // Get notification icon
    $scope.getNotificationIcon = function(type) {
        var icons = {
            'info': 'fa-info-circle',
            'success': 'fa-check-circle',
            'warning': 'fa-exclamation-triangle',
            'error': 'fa-times-circle',
            'grade': 'fa-star',
            'attendance': 'fa-clipboard-check',
            'system': 'fa-cog'
        };
        return icons[type] || 'fa-bell';
    };
    
    // Get notification badge class
    $scope.getNotificationClass = function(type) {
        var classes = {
            'info': 'badge-info',
            'success': 'badge-success',
            'warning': 'badge-warning',
            'error': 'badge-danger',
            'grade': 'badge-primary',
            'attendance': 'badge-info',
            'system': 'badge-secondary'
        };
        return classes[type] || 'badge-secondary';
    };
    
    // Format date
    $scope.formatDate = function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        return date.toLocaleString('vi-VN');
    };
    
    // Time ago helper
    $scope.timeAgo = function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        var now = new Date();
        var diff = now - date;
        
        var minutes = Math.floor(diff / 60000);
        var hours = Math.floor(diff / 3600000);
        var days = Math.floor(diff / 86400000);
        
        if (minutes < 1) return 'Vừa xong';
        if (minutes < 60) return minutes + ' phút trước';
        if (hours < 24) return hours + ' giờ trước';
        if (days < 7) return days + ' ngày trước';
        return date.toLocaleDateString('vi-VN');
    };
    
    // Initialize
    $scope.loadNotifications();
}]);

// Notification Bell Controller (for header)
app.controller('NotificationBellController', ['$scope', 'NotificationService',
    function($scope, NotificationService) {
    
    $scope.unreadNotifications = [];
    $scope.unreadCount = 0;
    $scope.showDropdown = false;
    
    // Load unread notifications
    $scope.loadUnread = function() {
        NotificationService.getUnread()
            .then(function(response) {
                $scope.unreadNotifications = response.data.slice(0, 5); // Show only 5 latest
                $scope.unreadCount = response.data.length;
                NotificationService.setUnreadCount(response.data.length);
            })
            .catch(function(error) {
                console.error('Error loading unread notifications:', error);
            });
    };
    
    // Toggle dropdown
    $scope.toggleDropdown = function() {
        $scope.showDropdown = !$scope.showDropdown;
        if ($scope.showDropdown) {
            $scope.loadUnread();
        }
    };
    
    // Mark as read and navigate
    $scope.markAndView = function(notification) {
        NotificationService.markAsRead(notification.id)
            .then(function() {
                $scope.loadUnread();
                // Navigate to related page if applicable
                if (notification.link) {
                    window.location.href = notification.link;
                }
            });
    };
    
    // View all notifications
    $scope.viewAll = function() {
        window.location.href = '#!/notifications';
    };
    
    // Listen to count changes
    $scope.$on('notificationCountChanged', function(event, count) {
        $scope.unreadCount = count;
    });
    
    // Initialize
    $scope.loadUnread();
    
    // Refresh every 60 seconds
    setInterval(function() {
        $scope.loadUnread();
        $scope.$apply();
    }, 60000);
}]);

