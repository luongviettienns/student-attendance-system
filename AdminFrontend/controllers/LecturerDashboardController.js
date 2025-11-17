// Lecturer Dashboard Controller
app.controller('LecturerDashboardController', ['$scope', 'AuthService', 'AvatarService', 'TimetableApi', 'LoggerService', 
    function($scope, AuthService, AvatarService, TimetableApi, LoggerService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = false;
    $scope.todaySchedule = [];
    $scope.stats = {
        totalClasses: 5,
        totalStudents: 180,
        todayClasses: 0,
        warningStudents: 8
    };
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Helper function to get ISO week
    function getIsoWeek(d) {
        var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        var dayNum = date.getUTCDay() || 7;
        date.setUTCDate(date.getUTCDate() + 4 - dayNum);
        var yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
        var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1) / 7);
        return { year: date.getUTCFullYear(), week: weekNo };
    }
    
    // Get current weekday (1 = Monday, 7 = Sunday)
    function getCurrentWeekday() {
        var today = new Date();
        var day = today.getDay();
        return day === 0 ? 7 : day; // Convert Sunday (0) to 7
    }
    
    // Format time from HH:mm:ss to HH:mm
    function formatTime(timeString) {
        if (!timeString) return '';
        // Handle string format (HH:mm:ss or HH:mm)
        if (typeof timeString === 'string') {
            // If it's already in HH:mm format, return as is
            if (timeString.length === 5 && timeString.indexOf(':') === 2) {
                return timeString;
            }
            // Otherwise, get HH:mm from HH:mm:ss
            return timeString.substring(0, 5);
        }
        // If it's an object (TimeSpan), try to convert
        if (typeof timeString === 'object' && timeString !== null) {
            // Handle TimeSpan object if it has hours/minutes properties
            if (timeString.hours !== undefined && timeString.minutes !== undefined) {
                var h = ('0' + String(timeString.hours)).slice(-2);
                var m = ('0' + String(timeString.minutes)).slice(-2);
                return h + ':' + m;
            }
        }
        return String(timeString);
    }
    
    // Determine status based on current time
    function getStatus(startTime, endTime) {
        var now = new Date();
        var currentTime = now.getHours() * 100 + now.getMinutes(); // HHMM format
        
        var start = parseInt(startTime.replace(':', ''));
        var end = parseInt(endTime.replace(':', ''));
        
        if (currentTime < start) {
            return 'pending';
        } else if (currentTime >= start && currentTime <= end) {
            return 'in_progress';
        } else {
            return 'completed';
        }
    }
    
    // Load today's schedule
    function loadTodaySchedule() {
        var lecturerId = $scope.currentUser && ($scope.currentUser.lecturerId || $scope.currentUser.userId);
        if (!lecturerId) {
            $scope.todaySchedule = [];
            $scope.stats.todayClasses = 0;
            $scope.loading = false;
            return;
        }
        
        $scope.loading = true;
        var today = new Date();
        var iso = getIsoWeek(today);
        var currentWeekday = getCurrentWeekday();
        
        TimetableApi.getLecturerWeek(lecturerId, iso.year, iso.week)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                
                // Filter today's schedule
                var todaySchedules = data.filter(function(schedule) {
                    return schedule.weekday === currentWeekday;
                });
                
                // Sort by start time
                todaySchedules.sort(function(a, b) {
                    var timeA = a.start_time || a.startTime || '';
                    var timeB = b.start_time || b.startTime || '';
                    return timeA.localeCompare(timeB);
                });
                
                // Format data for display
                $scope.todaySchedule = todaySchedules.map(function(schedule) {
                    var startTime = formatTime(schedule.start_time || schedule.startTime || '');
                    var endTime = formatTime(schedule.end_time || schedule.endTime || '');
                    var period = (schedule.period_from && schedule.period_to) 
                        ? schedule.period_from + '-' + schedule.period_to 
                        : (schedule.periodFrom && schedule.periodTo)
                        ? schedule.periodFrom + '-' + schedule.periodTo
                        : '';
                    
                    return {
                        id: schedule.session_id || schedule.sessionId || '',
                        period: period,
                        subjectName: schedule.subject_name || schedule.subjectName || 'N/A',
                        className: schedule.class_name || schedule.className || 'N/A',
                        room: schedule.room_code || schedule.roomCode || 'N/A',
                        startTime: startTime,
                        endTime: endTime,
                        status: getStatus(startTime, endTime)
                    };
                });
                
                // Update stats
                $scope.stats.todayClasses = $scope.todaySchedule.length;
            })
            .catch(function(err) {
                LoggerService.error('Load today schedule error', err);
                $scope.todaySchedule = [];
                $scope.stats.todayClasses = 0;
            })
            .finally(function() {
                $scope.loading = false;
            });
    }
    
    // Initialize
    loadTodaySchedule();
}]);

