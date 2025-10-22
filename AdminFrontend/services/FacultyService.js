// Faculty Service
app.service('FacultyService', ['ApiService', function(ApiService) {
    
    this.getAll = function(page, pageSize, search) {
        var params = {
            page: page || 1,
            pageSize: pageSize || 10
        };
        
        if (search) {
            params.search = search;
        }
        
        return ApiService.get('/faculties', { params: params });
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

