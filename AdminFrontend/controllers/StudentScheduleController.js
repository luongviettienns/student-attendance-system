// Student Schedule Controller
app.controller('StudentScheduleController', ['$scope', 'AuthService', function($scope, AuthService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.currentWeekRange = '21/10/2025 - 27/10/2025';
    
    // Period definitions
    $scope.periods = [
        { name: 'Tiết 1-2', value: '1-2', time: '07:00 - 08:50' },
        { name: 'Tiết 3-4', value: '3-4', time: '09:00 - 10:50' },
        { name: 'Tiết 5-6', value: '5-6', time: '11:00 - 12:50' },
        { name: 'Tiết 6-7', value: '6-7', time: '13:00 - 14:50' },
        { name: 'Tiết 8-9', value: '8-9', time: '15:00 - 16:50' },
        { name: 'Tiết 10-11', value: '10-11', time: '17:00 - 18:50' }
    ];
    
    // Demo schedule data (day of week, period, subject info)
    $scope.weeklySchedule = [
        // Monday (2)
        { dayOfWeek: 2, period: '1-2', subjectName: 'Lập trình Web', lecturerName: 'TS. Nguyễn Văn B', room: 'A101' },
        { dayOfWeek: 2, period: '6-7', subjectName: 'Cơ sở dữ liệu', lecturerName: 'ThS. Trần Thị C', room: 'B205' },
        // Tuesday (3)
        { dayOfWeek: 3, period: '3-4', subjectName: 'Kiến trúc máy tính', lecturerName: 'PGS.TS. Lê Văn D', room: 'C310' },
        // Wednesday (4)
        { dayOfWeek: 4, period: '1-2', subjectName: 'Lập trình Web', lecturerName: 'TS. Nguyễn Văn B', room: 'A101' },
        { dayOfWeek: 4, period: '6-7', subjectName: 'Tiếng Anh chuyên ngành', lecturerName: 'ThS. Phạm Thị E', room: 'D401' },
        // Thursday (5)
        { dayOfWeek: 5, period: '3-4', subjectName: 'Cơ sở dữ liệu', lecturerName: 'ThS. Trần Thị C', room: 'B205' },
        { dayOfWeek: 5, period: '8-9', subjectName: 'Giáo dục thể chất', lecturerName: 'Th.S Hoàng Văn F', room: 'Sân VĐ' },
        // Friday (6)
        { dayOfWeek: 6, period: '1-2', subjectName: 'Kiến trúc máy tính', lecturerName: 'PGS.TS. Lê Văn D', room: 'C310' },
        { dayOfWeek: 6, period: '3-4', subjectName: 'Toán rời rạc', lecturerName: 'TS. Vũ Thị G', room: 'E201' }
    ];
    
    // Schedule list with dates
    $scope.scheduleList = [
        { dayOfWeek: 2, date: '21/10/2025', period: '1-2', startTime: '07:00', endTime: '08:50', subjectName: 'Lập trình Web', lecturerName: 'TS. Nguyễn Văn B', room: 'A101' },
        { dayOfWeek: 2, date: '21/10/2025', period: '6-7', startTime: '13:00', endTime: '14:50', subjectName: 'Cơ sở dữ liệu', lecturerName: 'ThS. Trần Thị C', room: 'B205' },
        { dayOfWeek: 3, date: '22/10/2025', period: '3-4', startTime: '09:00', endTime: '10:50', subjectName: 'Kiến trúc máy tính', lecturerName: 'PGS.TS. Lê Văn D', room: 'C310' },
        { dayOfWeek: 4, date: '23/10/2025', period: '1-2', startTime: '07:00', endTime: '08:50', subjectName: 'Lập trình Web', lecturerName: 'TS. Nguyễn Văn B', room: 'A101' },
        { dayOfWeek: 4, date: '23/10/2025', period: '6-7', startTime: '13:00', endTime: '14:50', subjectName: 'Tiếng Anh chuyên ngành', lecturerName: 'ThS. Phạm Thị E', room: 'D401' },
        { dayOfWeek: 5, date: '24/10/2025', period: '3-4', startTime: '09:00', endTime: '10:50', subjectName: 'Cơ sở dữ liệu', lecturerName: 'ThS. Trần Thị C', room: 'B205' },
        { dayOfWeek: 5, date: '24/10/2025', period: '8-9', startTime: '15:00', endTime: '16:50', subjectName: 'Giáo dục thể chất', lecturerName: 'Th.S Hoàng Văn F', room: 'Sân VĐ' },
        { dayOfWeek: 6, date: '25/10/2025', period: '1-2', startTime: '07:00', endTime: '08:50', subjectName: 'Kiến trúc máy tính', lecturerName: 'PGS.TS. Lê Văn D', room: 'C310' },
        { dayOfWeek: 6, date: '25/10/2025', period: '3-4', startTime: '09:00', endTime: '10:50', subjectName: 'Toán rời rạc', lecturerName: 'TS. Vũ Thị G', room: 'E201' }
    ];
    
    $scope.getSchedule = function(day, period) {
        return $scope.weeklySchedule.find(function(item) {
            return item.dayOfWeek === day && item.period === period;
        });
    };
    
    $scope.getDayName = function(dayOfWeek) {
        var days = ['', 'Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
        return days[dayOfWeek];
    };
    
    $scope.previousWeek = function() {
        alert('Chức năng xem tuần trước');
    };
    
    $scope.nextWeek = function() {
        alert('Chức năng xem tuần sau');
    };
}]);

