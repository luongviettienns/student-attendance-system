// Student Dashboard Controller
app.controller('StudentDashboardController', ['$scope', 'AuthService', 'AvatarService', 'TimetableApi', 'StudentService', 'ReportService', 'LoggerService', 
    function($scope, AuthService, AvatarService, TimetableApi, StudentService, ReportService, LoggerService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = false;
    $scope.todaySchedule = [];
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Student info
    $scope.studentInfo = {
        fullName: '',
        studentCode: '',
        className: '',
        faculty: '',
        academicYear: '',
        gpa: 0,
        credits: 0,
        attendanceRate: 0
    };
    
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
        return timeString.substring(0, 5); // Get HH:mm from HH:mm:ss
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
        if (!$scope.studentId) {
            $scope.todaySchedule = [];
            return;
        }
        
        $scope.loading = true;
        var today = new Date();
        var iso = getIsoWeek(today);
        var currentWeekday = getCurrentWeekday();
        
        TimetableApi.getStudentWeek($scope.studentId, iso.year, iso.week)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                
                // Filter today's schedule
                var todaySchedules = data.filter(function(schedule) {
                    return schedule.weekday === currentWeekday;
                });
                
                // Sort by start time
                todaySchedules.sort(function(a, b) {
                    var timeA = a.start_time || '';
                    var timeB = b.start_time || '';
                    return timeA.localeCompare(timeB);
                });
                
                // Format data for display
                $scope.todaySchedule = todaySchedules.map(function(schedule) {
                    var startTime = formatTime(schedule.start_time || '');
                    var endTime = formatTime(schedule.end_time || '');
                    var period = (schedule.period_from && schedule.period_to) 
                        ? schedule.period_from + '-' + schedule.period_to 
                        : '';
                    
                    return {
                        period: period,
                        subjectName: schedule.subject_name || 'N/A',
                        lecturerName: schedule.lecturer_name || 'N/A',
                        room: schedule.room_code || 'N/A',
                        startTime: startTime,
                        endTime: endTime,
                        status: getStatus(startTime, endTime)
                    };
                });
            })
            .catch(function(err) {
                LoggerService.error('Load today schedule error', err);
                $scope.todaySchedule = [];
            })
            .finally(function() {
                $scope.loading = false;
            });
    }
    
    // Load student ID and info
    function loadStudentInfo() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.loading = false;
            return;
        }
        
        // Load basic student info
        StudentService.getByUserId($scope.currentUser.userId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    var student = response.data.data;
                    $scope.studentId = student.studentId;
                    
                    // Update basic student info
                    $scope.studentInfo.fullName = student.fullName || '';
                    $scope.studentInfo.studentCode = student.studentCode || '';
                    $scope.studentInfo.className = student.className || '';
                    $scope.studentInfo.faculty = student.facultyName || '';
                    $scope.studentInfo.academicYear = student.academicYearName || '';
                    
                    // Load actual academic data from reports API (GPA, credits, attendance)
                    loadAcademicStats();
                    
                    // Load today's schedule
                    loadTodaySchedule();
                } else {
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                LoggerService.error('Load student info error', error);
                $scope.loading = false;
            });
    }
    
    // Load academic statistics (GPA, credits, attendance) from reports API
    function loadAcademicStats() {
        // Call reports API without filters to get all-time data
        ReportService.getStudentReports({})
            .then(function(res) {
                var data = (res.data && res.data.data) || res.data || {};
                var overview = data.overview || data.Overview || {};
                
                // Update academic stats with real data
                $scope.studentInfo.gpa = overview.cumulativeGpa || overview.CumulativeGpa || 0;
                $scope.studentInfo.credits = overview.creditsEarned || overview.CreditsEarned || 0;
                $scope.studentInfo.attendanceRate = overview.attendanceRate || overview.AttendanceRate || 0;
            })
            .catch(function(err) {
                LoggerService.error('Load academic stats error', err);
                // Keep default values (0) if error
            });
    }
    
    // Initialize
    loadStudentInfo();
}]);

