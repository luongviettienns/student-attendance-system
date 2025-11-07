// Enrollment Service
app.service('EnrollmentService', ['ApiService', function(ApiService) {
    
    // GET BY STUDENT
    this.getByStudent = function(studentId) {
        return ApiService.get('/enrollments/student/' + studentId);
    };
    
    // REGISTER
    this.register = function(studentId, classId, notes) {
        return ApiService.post('/enrollments/register', {
            studentId: studentId,
            classId: classId,
            notes: notes
        });
    };
    
    // DROP (Student)
    this.drop = function(enrollmentId, reason) {
        return ApiService.post('/enrollments/' + enrollmentId + '/drop', {
            reason: reason
        });
    };
    
    // GET SUMMARY (Student)
    this.getSummary = function(studentId, semester, academicYearId) {
        const params = {};
        if (semester) params.semester = semester;
        if (academicYearId) params.academicYearId = academicYearId;
        
        return ApiService.get('/enrollments/student/' + studentId + '/summary', params);
    };
    
    // GET AVAILABLE CLASSES (Student)
    this.getAvailableClasses = function(studentId, semester, academicYearId) {
        const params = {};
        if (semester) params.semester = semester;
        if (academicYearId) params.academicYearId = academicYearId;
        
        return ApiService.get('/enrollments/student/' + studentId + '/available-classes', params);
    };
}]);


