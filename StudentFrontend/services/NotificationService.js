// Notification Service
app.service('NotificationService', ['ApiService', function(ApiService) {
    
    this.getAll = function() {
        return ApiService.get('/notifications');
    };
    
    this.getUnread = function() {
        return ApiService.get('/notifications/unread');
    };
    
    this.markAsRead = function(notificationId) {
        return ApiService.post('/notifications/' + notificationId + '/read');
    };
    
    this.markAllAsRead = function() {
        return ApiService.post('/notifications/read-all');
    };
}]);


