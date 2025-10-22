// Advisor Dashboard Controller
app.controller('AdvisorDashboardController', ['$scope', 'AuthService', 'AvatarService', function($scope, AuthService, AvatarService) {
    $scope.currentUser = AuthService.getCurrentUser();
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    $scope.stats = {
        totalStudents: 45,
        warningStudents: 8,
        lowGPAStudents: 5,
        excellentStudents: 12
    };
    
    // Demo warning students
    $scope.warningStudents = [
        {
            studentCode: 'SV001',
            fullName: 'Nguyễn Văn A',
            className: 'CNTT K16',
            gpa: 1.8,
            absenceRate: 25,
            warningType: 'both'
        },
        {
            studentCode: 'SV005',
            fullName: 'Trần Thị B',
            className: 'CNTT K16',
            gpa: 2.5,
            absenceRate: 22,
            warningType: 'attendance'
        },
        {
            studentCode: 'SV012',
            fullName: 'Lê Văn C',
            className: 'CNTT K17',
            gpa: 1.9,
            absenceRate: 15,
            warningType: 'gpa'
        },
        {
            studentCode: 'SV018',
            fullName: 'Phạm Thị D',
            className: 'CNTT K17',
            gpa: 1.5,
            absenceRate: 30,
            warningType: 'both'
        },
        {
            studentCode: 'SV023',
            fullName: 'Hoàng Văn E',
            className: 'CNTT K16',
            gpa: 3.2,
            absenceRate: 21,
            warningType: 'attendance'
        }
    ];
    
    // Demo recent consultations
    $scope.recentConsultations = [
        {
            studentName: 'Nguyễn Văn A',
            date: '21/10/2025 14:30',
            content: 'Tư vấn về việc cải thiện điểm chuyên cần và kế hoạch học tập'
        },
        {
            studentName: 'Trần Thị B',
            date: '20/10/2025 10:15',
            content: 'Hướng dẫn đăng ký học phần và lựa chọn môn tự chọn'
        },
        {
            studentName: 'Lê Văn C',
            date: '19/10/2025 16:00',
            content: 'Tư vấn về khó khăn trong học tập và phương pháp cải thiện'
        }
    ];
    
    $scope.contactStudent = function(student) {
        alert('Gửi email liên hệ đến sinh viên: ' + student.fullName);
    };
}]);

