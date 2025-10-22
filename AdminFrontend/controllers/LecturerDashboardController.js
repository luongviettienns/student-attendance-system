// Lecturer Dashboard Controller
app.controller('LecturerDashboardController', ['$scope', 'AuthService', 'AvatarService', function($scope, AuthService, AvatarService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = false;
    $scope.stats = {
        totalClasses: 5,
        totalStudents: 180,
        todayClasses: 3,
        warningStudents: 8
    };
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Demo data for today's schedule
    $scope.todaySchedule = [
        {
            id: 1,
            period: '1-2',
            subjectName: 'Lập trình Web',
            className: 'CNTT K16',
            room: 'A101',
            startTime: '07:00',
            endTime: '08:50',
            status: 'completed'
        },
        {
            id: 2,
            period: '3-4',
            subjectName: 'Cơ sở dữ liệu',
            className: 'CNTT K17',
            room: 'B205',
            startTime: '09:00',
            endTime: '10:50',
            status: 'in_progress'
        },
        {
            id: 3,
            period: '6-7',
            subjectName: 'Kiến trúc máy tính',
            className: 'CNTT K16',
            room: 'C310',
            startTime: '13:00',
            endTime: '14:50',
            status: 'pending'
        }
    ];
}]);

