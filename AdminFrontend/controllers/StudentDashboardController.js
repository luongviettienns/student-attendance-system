// Student Dashboard Controller
app.controller('StudentDashboardController', ['$scope', 'AuthService', 'AvatarService', function($scope, AuthService, AvatarService) {
    $scope.currentUser = AuthService.getCurrentUser();
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Demo student info
    $scope.studentInfo = {
        fullName: 'Nguyễn Văn A',
        studentCode: 'SV001',
        className: 'CNTT K16',
        faculty: 'Công nghệ Thông tin',
        academicYear: '2020-2024',
        gpa: 3.45,
        credits: 98,
        attendanceRate: 92
    };
    
    // Demo today's schedule
    $scope.todaySchedule = [
        {
            period: '1-2',
            subjectName: 'Lập trình Web',
            lecturerName: 'TS. Nguyễn Văn B',
            room: 'A101',
            startTime: '07:00',
            endTime: '08:50',
            status: 'completed'
        },
        {
            period: '3-4',
            subjectName: 'Cơ sở dữ liệu',
            lecturerName: 'ThS. Trần Thị C',
            room: 'B205',
            startTime: '09:00',
            endTime: '10:50',
            status: 'in_progress'
        },
        {
            period: '6-7',
            subjectName: 'Kiến trúc máy tính',
            lecturerName: 'PGS.TS. Lê Văn D',
            room: 'C310',
            startTime: '13:00',
            endTime: '14:50',
            status: 'pending'
        }
    ];
}]);

