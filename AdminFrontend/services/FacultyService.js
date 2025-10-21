// Faculty Service
app.service('FacultyService', ['ApiService', function(ApiService) {
    
    this.getAll = function() {
        return ApiService.get('/faculties').then(function(response) {
            // Xử lý response format từ backend
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    this.getById = function(id) {
        return ApiService.get('/faculties/' + id);
    };
    
    this.create = function(faculty) {
        return ApiService.post('/faculties', faculty);
    };
    
    this.update = function(id, faculty) {
        return ApiService.put('/faculties/' + id, faculty);
    };
    
    this.delete = function(id) {
        return ApiService.delete('/faculties/' + id);
    };
}]);

