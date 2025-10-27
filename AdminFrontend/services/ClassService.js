// Class Service
app.service('ClassService', ['ApiService', function(ApiService) {
    
    this.getAll = function(params) {
        return ApiService.get('/classes', params).then(function(response) {
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    this.getById = function(id) {
        return ApiService.get('/classes/' + id);
    };
    
    this.create = function(classData) {
        return ApiService.post('/classes', classData);
    };
    
    this.update = function(id, classData) {
        return ApiService.put('/classes/' + id, classData);
    };
    
    this.delete = function(id) {
        return ApiService.delete('/classes/' + id);
    };
    
    this.getByLecturer = function(lecturerId) {
        return ApiService.get('/classes/lecturer/' + lecturerId);
    };
    
    this.getByStudent = function(studentId) {
        return ApiService.get('/classes/student/' + studentId);
    };
}]);

