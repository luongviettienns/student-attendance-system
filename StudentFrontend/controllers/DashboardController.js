// Student Dashboard Controller
app.controller('DashboardController', ['$scope', 'AuthService', 'StudentService', 'AvatarService', 'TimetableApi', function($scope, AuthService, StudentService, AvatarService, TimetableApi) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = true;
    $scope.studentInfo = null;
    $scope.todaySchedule = [];
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Load student info
    function loadStudentInfo() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.loading = false;
            return;
        }
        
        // Check if studentId is already in currentUser
        if ($scope.currentUser.studentId) {
            // Create studentInfo object from currentUser
            $scope.studentInfo = {
                studentId: $scope.currentUser.studentId,
                fullName: $scope.currentUser.fullName,
                email: $scope.currentUser.email
            };
            loadTodaySchedule();
            return;
        }
        
        // Otherwise, fetch from API
        StudentService.getByUserId($scope.currentUser.userId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.studentInfo = response.data.data;
                    loadTodaySchedule();
                } else {
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                console.error('Error loading student info:', error);
                $scope.loading = false;
            });
    }
    
    // Load today's schedule
    function loadTodaySchedule() {
        if (!$scope.studentInfo || !$scope.studentInfo.studentId) {
            $scope.loading = false;
            return;
        }
        
        var today = new Date();
        var iso = getIsoWeek(today);
        
        TimetableApi.getStudentWeek($scope.studentInfo.studentId, iso.year, iso.week)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                var todayDayOfWeek = today.getDay(); // 0 = Sunday, 1 = Monday, etc.
                // Convert to ISO weekday (1 = Monday, 7 = Sunday)
                var isoWeekday = todayDayOfWeek === 0 ? 7 : todayDayOfWeek;
                
                // Filter today's sessions
                $scope.todaySchedule = data.filter(function(s) {
                    return s.weekday === isoWeekday;
                }).map(function(s) {
                    var now = new Date();
                    var startTime = parseTime(s.startTime);
                    var endTime = parseTime(s.endTime);
                    var status = 'pending';
                    
                    if (now > endTime) {
                        status = 'completed';
                    } else if (now >= startTime && now <= endTime) {
                        status = 'in_progress';
                    }
                    
                    return {
                        period: s.period || 'N/A',
                        subjectName: s.subjectName || 'N/A',
                        lecturerName: s.lecturerName || 'N/A',
                        room: s.roomCode || 'N/A',
                        startTime: s.startTime || 'N/A',
                        endTime: s.endTime || 'N/A',
                        status: status
                    };
                });
                
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading schedule:', error);
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
    
    function parseTime(timeStr) {
        if (!timeStr) return new Date();
        var parts = timeStr.split(':');
        var date = new Date();
        date.setHours(parseInt(parts[0]), parseInt(parts[1] || 0), 0, 0);
        return date;
    }
    
    // Initialize
    loadStudentInfo();
}]);


