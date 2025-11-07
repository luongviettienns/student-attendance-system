// Notification Bell Directive (Simplified for students)
app.directive('notificationBell', ['NotificationService', function(NotificationService) {
    return {
        restrict: 'E',
        scope: {},
        template: 
            '<div class="notification-bell">' +
                '<button class="notification-bell-btn" ng-click="toggleDropdown()" ng-class="{\'active\': showDropdown}">' +
                    '<i class="fas fa-bell"></i>' +
                    '<span ng-if="unreadCount > 0" class="notification-badge">{{unreadCount > 99 ? \'99+\' : unreadCount}}</span>' +
                '</button>' +
                '<div ng-if="showDropdown" class="notification-dropdown-wrapper">' +
                    '<div class="notification-dropdown" ng-click="$event.stopPropagation()">' +
                        '<div class="notification-dropdown-header">' +
                            '<h4><i class="fas fa-bell"></i> Thông báo</h4>' +
                            '<button ng-click="showDropdown = false" class="close-btn">' +
                                '<i class="fas fa-times"></i>' +
                            '</button>' +
                        '</div>' +
                        '<div class="notification-dropdown-body">' +
                            '<div ng-if="notifications.length === 0" class="empty-notifications">' +
                                '<i class="fas fa-inbox"></i>' +
                                '<p>Không có thông báo</p>' +
                            '</div>' +
                            '<div ng-repeat="notif in notifications" ' +
                                 'class="notification-dropdown-item" ' +
                                 'ng-click="markAsRead(notif)">' +
                                '<div class="notif-content">' +
                                    '<h5>{{notif.title}}</h5>' +
                                    '<p>{{notif.message}}</p>' +
                                    '<span class="notif-time">{{notif.createdAt | date:\'short\'}}</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>',
        link: function(scope, element) {
            scope.showDropdown = false;
            scope.notifications = [];
            scope.unreadCount = 0;
            
            // Load notifications
            function loadNotifications() {
                NotificationService.getUnread()
                    .then(function(response) {
                        if (response.data && response.data.data) {
                            scope.notifications = response.data.data;
                            scope.unreadCount = scope.notifications.length;
                        }
                    })
                    .catch(function(error) {
                        console.error('Error loading notifications:', error);
                    });
            }
            
            // Toggle dropdown
            scope.toggleDropdown = function() {
                scope.showDropdown = !scope.showDropdown;
                if (scope.showDropdown) {
                    loadNotifications();
                }
            };
            
            // Mark as read
            scope.markAsRead = function(notif) {
                NotificationService.markAsRead(notif.notificationId)
                    .then(function() {
                        loadNotifications();
                    });
            };
            
            // Close dropdown when clicking outside
            angular.element(document).on('click', function(e) {
                if (!element[0].contains(e.target)) {
                    scope.$evalAsync(function() {
                        scope.showDropdown = false;
                    });
                }
            });
            
            // Initial load
            loadNotifications();
            
            // Cleanup
            scope.$on('$destroy', function() {
                angular.element(document).off('click');
            });
        }
    };
}]);


