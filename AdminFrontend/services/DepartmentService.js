// Department Service
app.service('DepartmentService', ['ApiService', function(ApiService) {
    
    // ============================================================
    // 🔹 Lấy danh sách tất cả bộ môn
    // ============================================================
    this.getAll = function() {
        return ApiService.get('/admin/department');
    };
    
    // ============================================================
    // 🔹 Lấy chi tiết bộ môn theo ID
    // ============================================================
    this.getById = function(id) {
        return ApiService.get('/admin/department/' + id);
    };
    
    // ============================================================
    // 🔹 Lấy danh sách bộ môn theo khoa
    // ============================================================
    this.getByFaculty = function(facultyId) {
        return ApiService.get('/admin/department/faculty/' + facultyId);
    };
    
    // ============================================================
    // 🔹 Tạo bộ môn mới
    // ============================================================
    this.create = function(department) {
        return ApiService.post('/admin/department', department);
    };
    
    // ============================================================
    // 🔹 Cập nhật bộ môn
    // ============================================================
    this.update = function(id, department) {
        return ApiService.put('/admin/department/' + id, department);
    };
    
    // ============================================================
    // 🔹 Xóa bộ môn
    // ============================================================
    this.delete = function(id) {
        return ApiService.delete('/admin/department/' + id);
    };
    
    // ============================================================
    // 🔹 Thống kê số môn học theo bộ môn
    // ============================================================
    this.getSubjectStats = function() {
        return ApiService.get('/admin/department/stats/subjects');
    };
    
    // ============================================================
    // 🔹 Thống kê số giảng viên theo bộ môn
    // ============================================================
    this.getLecturerStats = function() {
        return ApiService.get('/admin/department/stats/lecturers');
    };
}]);

