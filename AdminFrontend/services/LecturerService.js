// Lecturer Service
app.service('LecturerService', ['ApiService', function(ApiService) {
    
    this.getAll = function() {
        return ApiService.get('/lecturers');
    };
    
    this.getById = function(id) {
        return ApiService.get('/lecturers/' + id);
    };
    
    this.create = function(lecturer) {
        return ApiService.post('/lecturers', lecturer);
    };
    
    this.update = function(id, lecturer) {
        return ApiService.put('/lecturers/' + id, lecturer);
    };
    
    this.delete = function(id) {
        return ApiService.delete('/lecturers/' + id);
    };
}]);

