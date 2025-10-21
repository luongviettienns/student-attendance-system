// Audit Log Service
app.service('AuditLogService', ['ApiService', function(ApiService) {
    
    this.getAll = function(params) {
        return ApiService.get('/auditlog', params).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    this.getById = function(id) {
        return ApiService.get('/auditlog/' + id);
    };
    
    this.getByUser = function(userId) {
        return ApiService.get('/auditlog/user/' + userId);
    };
    
    this.getByEntity = function(entityType, entityId) {
        return ApiService.get('/auditlog/entity/' + entityType + '/' + entityId);
    };
    
    this.search = function(filters) {
        return ApiService.post('/auditlog/search', filters);
    };
}]);

