// Student Schedule Controller
app.controller('ScheduleController', ['$scope', '$timeout', 'AuthService', 'TimetableApi', 'StudentService', function($scope, $timeout, AuthService, TimetableApi, StudentService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.loading = false;
    $scope.studentId = null;
    $scope.currentWeekRange = '';
    $scope.currentYear = 2025;
    $scope.currentWeek = '12'; // Week 12 starts from 3/11/2025 - Keep as string to match select value
    $scope.availableWeeks = []; // Danh sách các tuần có thể chọn
    
    // Period definitions - Bao gồm tất cả các period có thể có
    $scope.periods = [
        { name: 'Tiết 1-2', value: '1-2', time: '07:00 - 08:50' },
        { name: 'Tiết 2-3', value: '2-3', time: '08:00 - 09:50' },
        { name: 'Tiết 3-4', value: '3-4', time: '09:00 - 10:50' },
        { name: 'Tiết 5-6', value: '5-6', time: '11:00 - 12:50' },
        { name: 'Tiết 6-7', value: '6-7', time: '13:00 - 14:50' },
        { name: 'Tiết 8-9', value: '8-9', time: '15:00 - 16:50' },
        { name: 'Tiết 10-11', value: '10-11', time: '17:00 - 18:50' }
    ];
    
    $scope.weeklySchedule = [];
    $scope.scheduleList = [];
    
    // Helper: Get start date of a week based on week 12 starting from 03/11/2025 (Monday)
    function getWeekStartDate(year, week) {
        // Week 12 starts on 03/11/2025 (Monday) - Tuần 12 = 03/11/2025 - 09/11/2025
        var week12StartDate = new Date(2025, 10, 3); // Month is 0-indexed, so 10 = November, day 3 = 03/11/2025
        // Calculate the start date for week 1 (11 weeks before week 12)
        var week1StartDate = new Date(week12StartDate);
        week1StartDate.setDate(week1StartDate.getDate() - (12 - 1) * 7);
        
        // Calculate the start date for the requested week
        var weekStartDate = new Date(week1StartDate);
        weekStartDate.setDate(weekStartDate.getDate() + (week - 1) * 7);
        
        return weekStartDate;
    }
    
    // Helper: Get date for a specific weekday in a week
    function getDateForWeekday(year, week, weekday) {
        var weekStart = getWeekStartDate(year, week);
        // weekday trong database: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        // weekStart là Thứ 2 (Monday) = weekday 2
        // dayOffset: Monday (weekday=2) = 0, Tuesday (weekday=3) = 1, ..., Sunday (weekday=1) = 6
        var dayOffset = weekday - 2; // Monday (2) is 0 days offset, Tuesday (3) is 1, etc.
        if (dayOffset < 0) dayOffset += 7; // Sunday (1) = 6 days offset
        var date = new Date(weekStart);
        date.setDate(weekStart.getDate() + dayOffset);
        return date;
    }
    
    // Helper: Format date to DD/MM/YYYY
    function formatDate(date) {
        if (!date) return '';
        var day = ('0' + date.getDate()).slice(-2);
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var year = date.getFullYear();
        return day + '/' + month + '/' + year;
    }
    
    // Generate available weeks for dropdown
    function generateAvailableWeeks() {
        $scope.availableWeeks = [];
        // Tạo danh sách từ tuần 1 đến tuần 20 (có thể điều chỉnh)
        for (var weekNo = 1; weekNo <= 20; weekNo++) {
            var weekStart = getWeekStartDate($scope.currentYear, weekNo);
            var weekEnd = new Date(weekStart);
            weekEnd.setDate(weekStart.getDate() + 6); // Chủ nhật
            
            var label = 'Tuần ' + weekNo + ' [Từ ' + formatDate(weekStart) + ' -- ' + formatDate(weekEnd) + ']';
            $scope.availableWeeks.push({
                weekNo: weekNo, // Đảm bảo là number
                label: label,
                startDate: weekStart,
                endDate: weekEnd
            });
        }
        console.log('Generated weeks:', $scope.availableWeeks.length, 'weeks');
        console.log('Current week:', $scope.currentWeek, 'Type:', typeof $scope.currentWeek);
    }
    
    // Handle week change from dropdown
    $scope.onWeekChange = function() {
        // Read value directly from DOM element immediately (before ng-model updates)
        var selectElement = document.getElementById('weekSelect');
        var selectedValue = selectElement ? selectElement.value : null;
        
        // If DOM value is not available, try to get from scope (should be updated by ng-model)
        if (!selectedValue || selectedValue === '') {
            selectedValue = $scope.currentWeek;
        }
        
        console.log('onWeekChange - Selected value from DOM:', selectedValue, 'Type:', typeof selectedValue);
        console.log('onWeekChange - currentWeek in scope:', $scope.currentWeek, 'Type:', typeof $scope.currentWeek);
        
        // Convert to number for validation and API call
        var newWeek = parseInt(selectedValue);
        console.log('Parsed week:', newWeek, 'from value:', selectedValue);
        
        if (!isNaN(newWeek) && newWeek >= 1 && newWeek <= 20) {
            // Update scope with the selected value (as string to match value attribute)
            // Use $timeout to ensure AngularJS processes the update
            $timeout(function() {
                $scope.currentWeek = selectedValue.toString();
                console.log('Updated currentWeek to:', $scope.currentWeek, 'Type:', typeof $scope.currentWeek);
                console.log('Loading schedule for week:', newWeek);
                loadSchedule();
            }, 0);
        } else {
            console.error('Invalid week number:', selectedValue, 'parsed as:', newWeek);
        }
    };
    
    // Helper: Convert period from API format (e.g., "1-2", "3-4") to match our period values
    function normalizePeriod(periodFrom, periodTo) {
        if (!periodFrom || !periodTo) return null;
        // Convert to string if they're numbers
        var from = String(periodFrom);
        var to = String(periodTo);
        return from + '-' + to;
    }
    
    // Helper: Format time from "HH:mm:ss" to "HH:mm"
    function formatTime(timeStr) {
        if (!timeStr) return 'N/A';
        var str = String(timeStr);
        // If it's in "HH:mm:ss" format, take first 5 characters
        if (str.length >= 5) {
            return str.substring(0, 5);
        }
        return str;
    }
    
    // Load student ID
    function loadStudentId() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.loading = false;
            return;
        }
        
        // Check if studentId is already in currentUser
        if ($scope.currentUser.studentId) {
            $scope.studentId = $scope.currentUser.studentId;
            loadSchedule();
            return;
        }
        
        // Otherwise, fetch from API
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
                console.error('Error loading student info:', error);
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
        
        // Debug: Log current week being loaded
        var weekToLoad = parseInt($scope.currentWeek) || $scope.currentWeek;
        console.log('Loading schedule for week:', weekToLoad, 'year:', $scope.currentYear, 'Type:', typeof weekToLoad);
        
        TimetableApi.getStudentWeek($scope.studentId, $scope.currentYear, weekToLoad)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                
                // Remove duplicates based on session_id
                var uniqueSessions = [];
                var seenSessionIds = {};
                data.forEach(function(s) {
                    var sessionId = s.sessionId || s.session_id;
                    if (sessionId && !seenSessionIds[sessionId]) {
                        seenSessionIds[sessionId] = true;
                        uniqueSessions.push(s);
                    } else if (!sessionId) {
                        // If no sessionId, use combination of fields to identify unique sessions
                        var uniqueKey = s.weekday + '-' + s.periodFrom + '-' + s.periodTo + '-' + s.subjectId + '-' + s.startTime;
                        if (!seenSessionIds[uniqueKey]) {
                            seenSessionIds[uniqueKey] = true;
                            uniqueSessions.push(s);
                        }
                    }
                });
                
                // Build weekly schedule with normalized period
                $scope.weeklySchedule = uniqueSessions.map(function(s) {
                    return {
                        weekday: s.weekday,
                        period: normalizePeriod(s.periodFrom, s.periodTo) || s.period || 'N/A',
                        subjectName: s.subjectName || 'N/A',
                        lecturerName: s.lecturerName || 'N/A',
                        room: s.roomCode || 'N/A',
                        startTime: formatTime(s.startTime),
                        endTime: formatTime(s.endTime)
                    };
                });
                
                // Build schedule list with dates
                var currentWeekNum = parseInt($scope.currentWeek) || $scope.currentWeek;
                $scope.scheduleList = uniqueSessions.map(function(s) {
                    var date = getDateForWeekday($scope.currentYear, currentWeekNum, s.weekday);
                    return {
                        dayOfWeek: s.weekday,
                        date: formatDate(date),
                        period: normalizePeriod(s.periodFrom, s.periodTo) || s.period || 'N/A',
                        startTime: formatTime(s.startTime),
                        endTime: formatTime(s.endTime),
                        subjectName: s.subjectName || 'N/A',
                        lecturerName: s.lecturerName || 'N/A',
                        room: s.roomCode || 'N/A'
                    };
                });
                
                // Set week range
                // Tuần 12 = 03/11/2025 (Thứ 2) - 09/11/2025 (Chủ nhật)
                // weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
                var currentWeekNum = parseInt($scope.currentWeek) || $scope.currentWeek;
                var weekStart = getDateForWeekday($scope.currentYear, currentWeekNum, 2); // Thứ 2
                var weekEnd = getDateForWeekday($scope.currentYear, currentWeekNum, 1); // Chủ nhật
                // Nếu weekEnd < weekStart, thì weekEnd là Chủ nhật của tuần đó (weekStart + 6 ngày)
                if (weekEnd < weekStart) {
                    weekEnd = new Date(weekStart);
                    weekEnd.setDate(weekStart.getDate() + 6);
                }
                $scope.currentWeekRange = formatDate(weekStart) + ' - ' + formatDate(weekEnd);
                
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading schedule:', error);
                $scope.loading = false;
            });
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
        var currentWeekNum = parseInt($scope.currentWeek) || 1;
        if (currentWeekNum > 1) {
            $scope.currentWeek = (currentWeekNum - 1).toString();
        } else {
            // Move to previous year, last week
            $scope.currentYear--;
            $scope.currentWeek = '52'; // Approximate
        }
        loadSchedule();
    };
    
    $scope.nextWeek = function() {
        var currentWeekNum = parseInt($scope.currentWeek) || 1;
        if (currentWeekNum < 52) {
            $scope.currentWeek = (currentWeekNum + 1).toString();
        } else {
            // Move to next year, week 1
            $scope.currentYear++;
            $scope.currentWeek = '1';
        }
        loadSchedule();
    };
    
    // Watch for currentWeek changes (backup method) - Disabled to avoid double loading
    // $scope.$watch('currentWeek', function(newVal, oldVal) {
    //     if (newVal !== oldVal && newVal !== null && newVal !== undefined) {
    //         console.log('$watch detected week change from', oldVal, 'to', newVal);
    //         var weekNum = parseInt(newVal);
    //         if (!isNaN(weekNum) && weekNum >= 1 && weekNum <= 20) {
    //             // Only load if it's a valid change
    //             if (oldVal !== null && oldVal !== undefined) {
    //                 loadSchedule();
    //             }
    //         }
    //     }
    // });
    
    // Initialize
    generateAvailableWeeks(); // Generate dropdown weeks list
    loadStudentId();
}]);
