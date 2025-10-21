// Notification Service
app.service('NotificationService', ['ApiService', '$rootScope', function(ApiService, $rootScope) {
    
    var unreadCount = 0;
    
    this.getAll = function() {
        return ApiService.get('/notifications').then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    this.getUnread = function() {
        return ApiService.get('/notifications/unread');
    };
    
    this.getUnreadCount = function() {
        return unreadCount;
    };
    
    this.setUnreadCount = function(count) {
        unreadCount = count;
        $rootScope.$broadcast('notificationCountChanged', count);
    };
    
    this.markAsRead = function(id) {
        return ApiService.put('/notifications/' + id + '/read', {})
            .then(function(response) {
                if (unreadCount > 0) {
                    unreadCount--;
                    $rootScope.$broadcast('notificationCountChanged', unreadCount);
                }
                return response;
            });
    };
    
    this.markAllAsRead = function() {
        return ApiService.put('/notifications/mark-all-read', {})
            .then(function(response) {
                unreadCount = 0;
                $rootScope.$broadcast('notificationCountChanged', 0);
                return response;
            });
    };
    
    this.deleteNotification = function(id) {
        return ApiService.delete('/notifications/' + id);
    };
    
    this.create = function(notification) {
        return ApiService.post('/notifications', notification);
    };
    
    this.sendEmail = function(emailData) {
        return ApiService.post('/notifications/send-email', emailData);
    };
    
    // Load unread count on init
    this.loadUnreadCount = function() {
        var self = this;
        this.getUnread()
            .then(function(response) {
                self.setUnreadCount(response.data.length || 0);
            })
            .catch(function(error) {
                console.error('Error loading unread count:', error);
            });
    };
}]);

