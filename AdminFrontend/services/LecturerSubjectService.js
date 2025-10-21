// Lecturer Subject Service
app.service('LecturerSubjectService', ['ApiService', function(ApiService) {
    
    // ============================================================
    // 🔹 Lấy danh sách môn học của giảng viên
    // ============================================================
    this.getSubjectsByLecturer = function(lecturerId) {
        return ApiService.get('/admin/lecturersubject/lecturer/' + lecturerId);
    };
    
    // ============================================================
    // 🔹 Lấy danh sách giảng viên có thể dạy môn học
    // ============================================================
    this.getLecturersBySubject = function(subjectId) {
        return ApiService.get('/admin/lecturersubject/subject/' + subjectId);
    };
    
    // ============================================================
    // 🔹 Lấy giảng viên khả dụng cho môn học (khi tạo lớp)
    // ============================================================
    this.getAvailableLecturersForSubject = function(subjectId) {
        return ApiService.get('/admin/lecturersubject/available/' + subjectId);
    };
    
    // ============================================================
    // 🔹 Phân môn cho giảng viên
    // ============================================================
    this.assignSubject = function(assignment) {
        return ApiService.post('/admin/lecturersubject', assignment);
    };
    
    // ============================================================
    // 🔹 Cập nhật phân môn
    // ============================================================
    this.update = function(id, assignment) {
        return ApiService.put('/admin/lecturersubject/' + id, assignment);
    };
    
    // ============================================================
    // 🔹 Xóa phân môn
    // ============================================================
    this.delete = function(id) {
        return ApiService.delete('/admin/lecturersubject/' + id);
    };
}]);

