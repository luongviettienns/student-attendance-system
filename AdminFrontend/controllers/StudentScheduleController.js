// Student Schedule Controller
app.controller('StudentScheduleController', ['$scope', 'AuthService', 'TimetableApi', 'StudentService', function($scope, AuthService, TimetableApi, StudentService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = false;
    $scope.studentId = null;
    $scope.currentWeekRange = '';
    
    // Period definitions
    $scope.periods = [
        { name: 'Tiết 1-2', value: '1-2', time: '07:00 - 08:50' },
        { name: 'Tiết 3-4', value: '3-4', time: '09:00 - 10:50' },
        { name: 'Tiết 5-6', value: '5-6', time: '11:00 - 12:50' },
        { name: 'Tiết 6-7', value: '6-7', time: '13:00 - 14:50' },
        { name: 'Tiết 8-9', value: '8-9', time: '15:00 - 16:50' },
        { name: 'Tiết 10-11', value: '10-11', time: '17:00 - 18:50' }
    ];
    
    $scope.weeklySchedule = [];
    $scope.scheduleList = [];
    
    // Load student ID
    function loadStudentId() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.loading = false;
            return;
        }
        
        StudentService.getByUserId($scope.currentUser.userId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.studentId = response.data.data.studentId;
                    loadSchedule();
                } else {
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                $scope.loading = false;
            });
    }
    
    // Load schedule
    function loadSchedule() {
        if (!$scope.studentId) {
            $scope.loading = false;
            return;
        }
        
        $scope.loading = true;
        var today = new Date();
        var iso = getIsoWeek(today);
        
        TimetableApi.getStudentWeek($scope.studentId, iso.year, iso.week)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                
                // Build weekly schedule
                $scope.weeklySchedule = data;
                
                // Build schedule list with dates
                $scope.scheduleList = data.map(function(s) {
                    var date = getDateForWeekday(iso.year, iso.week, s.weekday);
                    return {
                        dayOfWeek: s.weekday,
                        date: formatDate(date),
                        period: s.period || 'N/A',
                        startTime: s.startTime || 'N/A',
                        endTime: s.endTime || 'N/A',
                        subjectName: s.subjectName || 'N/A',
                        lecturerName: s.lecturerName || 'N/A',
                        room: s.roomCode || 'N/A'
                    };
                });
                
                // Set week range
                var weekStart = getDateForWeekday(iso.year, iso.week, 1);
                var weekEnd = getDateForWeekday(iso.year, iso.week, 7);
                $scope.currentWeekRange = formatDate(weekStart) + ' - ' + formatDate(weekEnd);
                
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.loading = false;
            });
    }
    
    function getIsoWeek(d) {
        var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        var dayNum = date.getUTCDay() || 7;
        date.setUTCDate(date.getUTCDate() + 4 - dayNum);
        var yearStart = new Date(Date.UTC(date.getUTCFullYear(),0,1));
        var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1)/7);
        return { year: date.getUTCFullYear(), week: weekNo };
    }
    
    function getDateForWeekday(year, week, weekday) {
        var date = new Date(year, 0, 1);
        var dayNum = date.getDay() || 7;
        var diff = (weekday - dayNum + 7) % 7;
        date.setDate(date.getDate() + (week - 1) * 7 + diff - 3);
        return date;
    }
    
    function formatDate(date) {
        if (!date) return '';
        var day = ('0' + date.getDate()).slice(-2);
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var year = date.getFullYear();
        return day + '/' + month + '/' + year;
    }
    
    $scope.getSchedule = function(day, period) {
        return $scope.weeklySchedule.find(function(item) {
            return item.weekday === day && item.period === period;
        });
    };
    
    $scope.getDayName = function(dayOfWeek) {
        var days = ['', 'Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
        return days[dayOfWeek] || '';
    };
    
    $scope.previousWeek = function() {
        // TODO: Implement previous week navigation
        alert('Chức năng xem tuần trước');
    };
    
    $scope.nextWeek = function() {
        // TODO: Implement next week navigation
        alert('Chức năng xem tuần sau');
    };
    
    // Initialize
    loadStudentId();
}]);

