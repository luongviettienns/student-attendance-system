// Student Service
app.service('StudentService', ['ApiService', function(ApiService) {
    
    this.getById = function(id) {
        return ApiService.get('/students/' + id);
    };
    
    this.getByUserId = function(userId) {
        return ApiService.get('/students/by-user-id/' + userId);
    };
}]);


