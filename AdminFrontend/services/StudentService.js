// Student Service
app.service('StudentService', ['ApiService', function(ApiService) {
    
    this.getAll = function() {
        return ApiService.get('/students').then(function(response) {
            // Backend trả về {data: [...], pagination: {...}}
            // Chuyển thành array cho controller
            if (response.data && response.data.data) {
                response.data = response.data.data;
            }
            return response;
        });
    };
    
    this.getById = function(id) {
        return ApiService.get('/students/' + id);
    };
    
    this.create = function(student) {
        return ApiService.post('/students/addstudent', student);
    };
    
    this.update = function(id, student) {
        return ApiService.put('/students/update', student);
    };
    
    this.delete = function(id) {
        return ApiService.delete('/students/delete', {studentId: id});
    };
}]);

