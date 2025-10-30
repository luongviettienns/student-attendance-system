// Enrollment Service
app.service('EnrollmentService', ['ApiService', function(ApiService) {
    
    // ============================================================
    // 1️⃣ GET ALL
    // ============================================================
    this.getAll = function() {
        return ApiService.get('/enrollments');
    };
    
    // ============================================================
    // 2️⃣ GET BY ID
    // ============================================================
    this.getById = function(id) {
        return ApiService.get('/enrollments/' + id);
    };
    
    // ============================================================
    // 3️⃣ GET BY STUDENT
    // ============================================================
    this.getByStudent = function(studentId) {
        return ApiService.get('/enrollments/student/' + studentId);
    };
    
    // ============================================================
    // 4️⃣ GET BY CLASS
    // ============================================================
    this.getByClass = function(classId) {
        return ApiService.get('/enrollments/class/' + classId);
    };
    
    // ============================================================
    // 5️⃣ REGISTER
    // ============================================================
    this.register = function(studentId, classId, notes) {
        return ApiService.post('/enrollments/register', {
            studentId: studentId,
            classId: classId,
            notes: notes
        });
    };
    
    // ============================================================
    // 6️⃣ APPROVE (Admin)
    // ============================================================
    this.approve = function(enrollmentId) {
        return ApiService.post('/enrollments/' + enrollmentId + '/approve');
    };
    
    // ============================================================
    // 7️⃣ DROP (Student)
    // ============================================================
    this.drop = function(enrollmentId, reason) {
        return ApiService.post('/enrollments/' + enrollmentId + '/drop', {
            reason: reason
        });
    };
    
    // ============================================================
    // 8️⃣ WITHDRAW (Admin)
    // ============================================================
    this.withdraw = function(enrollmentId, reason) {
        return ApiService.post('/enrollments/' + enrollmentId + '/withdraw', {
            reason: reason
        });
    };
    
    // ============================================================
    // 9️⃣ GET SUMMARY (Student)
    // ============================================================
    this.getSummary = function(studentId, semester, academicYearId) {
        const params = {};
        if (semester) params.semester = semester;
        if (academicYearId) params.academicYearId = academicYearId;
        
        return ApiService.get('/enrollments/student/' + studentId + '/summary', params);
    };
    
    // ============================================================
    // 🔟 GET AVAILABLE CLASSES (Student)
    // ============================================================
    this.getAvailableClasses = function(studentId, semester, academicYearId) {
        const params = {};
        if (semester) params.semester = semester;
        if (academicYearId) params.academicYearId = academicYearId;
        
        return ApiService.get('/enrollments/student/' + studentId + '/available-classes', params);
    };
}]);

