// Lecturer Attendance Controller
app.controller('LecturerAttendanceController', ['$scope', '$timeout', '$http', '$routeParams', '$location', '$rootScope', 'AuthService', 'ClassService', 'EnrollmentService', 'TimetableApi', 'ApiService', 'LoggerService', 'API_CONFIG', 'ToastService',
    function($scope, $timeout, $http, $routeParams, $location, $rootScope, AuthService, ClassService, EnrollmentService, TimetableApi, ApiService, LoggerService, API_CONFIG, ToastService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.selectedClass = '';
    $scope.loading = false;
    $scope.loadingStudents = false;
    
    // ✅ Get parameters from route or query string (dùng cả URLSearchParams và $location.search)
    var urlParams = new URLSearchParams(window.location.search);
    var locationParams = $location.search();
    
    $scope.sessionId = $routeParams.sessionId || urlParams.get('sessionId') || locationParams.sessionId || null;
    var classIdFromUrl = urlParams.get('classId') || locationParams.classId || null;
    var periodFromUrl = urlParams.get('period') || locationParams.period || null;
    
    // Initialize attendanceDate as string in YYYY-MM-DD format
    // Format immediately to prevent ngModel:datefmt errors
    (function() {
        var today = new Date();
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0');
        var day = String(today.getDate()).padStart(2, '0');
        $scope.attendanceDate = year + '-' + month + '-' + day;
    })();
    
    $scope.period = '';
    $scope.saving = false;
    
    // Load classes for lecturer
    $scope.classes = [];
    
    $scope.loadClasses = function() {
        // Return promise for chaining
        return new Promise(function(resolve, reject) {
        var lecturerId = $scope.currentUser && ($scope.currentUser.lecturerId || $scope.currentUser.userId || $scope.currentUser.relatedId);
        
        if (!lecturerId) {
            $scope.error = 'Không tìm thấy thông tin giảng viên';
            $scope.classes = [];
            return;
        }
        
        $scope.loading = true;
        ClassService.getByLecturer(lecturerId)
            .then(function(response) {
                var data = response.data;
                if (data && data.data) {
                    $scope.classes = data.data.map(function(cls) {
                        return {
                            id: cls.classId,
                            classId: cls.classId,
                            subjectName: cls.subjectName || 'N/A',
                            className: cls.classCode || cls.className || 'N/A'
                        };
                    });
                } else if (Array.isArray(data)) {
                    $scope.classes = data.map(function(cls) {
                        return {
                            id: cls.classId,
                            classId: cls.classId,
                            subjectName: cls.subjectName || 'N/A',
                            className: cls.classCode || cls.className || 'N/A'
                        };
                    });
                } else {
                    $scope.classes = [];
                }
            })
            .catch(function(error) {
                ToastService.error('Không thể tải danh sách lớp học');
                $scope.classes = [];
                reject(error);
            })
            .finally(function() {
                $scope.loading = false;
                resolve();
            });
        });
    };
    
    // Load students for selected class
    $scope.students = [];
    
    // ✅ Load existing attendance records (store in scope để dùng lại)
    $scope.existingAttendances = [];
    
    function loadExistingAttendance() {
        if (!$scope.sessionId || !$scope.attendanceDate) {
            $scope.existingAttendances = [];
            return Promise.resolve([]);
        }
        
        return ApiService.get('/attendances/schedule/' + $scope.sessionId, null, { cache: false })
            .then(function(response) {
                var attendances = (response.data && response.data.data) || [];
                
                // ✅ Filter attendance records của ngày được chọn
                var selectedDate = new Date($scope.attendanceDate);
                var selectedDateStr = selectedDate.getFullYear() + '-' + 
                              String(selectedDate.getMonth() + 1).padStart(2, '0') + '-' + 
                              String(selectedDate.getDate()).padStart(2, '0');
                
                var filtered = attendances.filter(function(att) {
                    var attDateValue = att.attendanceDate || att.attendance_date || att.date || att.Date || null;
                    
                    if (!attDateValue) {
                        return false;
                    }
                    
                    var attDate = new Date(attDateValue);
                    if (isNaN(attDate.getTime())) {
                        return false;
                    }
                    
                    var attDateStr = attDate.getFullYear() + '-' + 
                                   String(attDate.getMonth() + 1).padStart(2, '0') + '-' + 
                                   String(attDate.getDate()).padStart(2, '0');
                    
                    return attDateStr === selectedDateStr;
                });
                
                // ✅ Store in scope để dùng lại
                $scope.existingAttendances = filtered;
                
                return filtered;
            })
            .catch(function(error) {
                LoggerService.error('Error loading existing attendance', error);
                $scope.existingAttendances = [];
                return [];
            });
    }
    
    $scope.loadStudents = function() {
        if (!$scope.selectedClass) {
            $scope.students = [];
            return;
        }
        
        $scope.loadingStudents = true;
        
        // Load students và existing attendance records song song
        Promise.all([
            EnrollmentService.getClassRoster($scope.selectedClass),
            loadExistingAttendance()
        ])
            .then(function(results) {
                var rosterResponse = results[0];
                var existingAttendances = results[1];
                
                var data = rosterResponse.data;
                var roster = (data && data.data) ? data.data : (Array.isArray(data) ? data : []);
                
                // ✅ Tạo map từ attendance records để dễ lookup
                var attendanceMap = {};
                existingAttendances.forEach(function(att) {
                    var studentId = att.student_id || att.studentId;
                    attendanceMap[studentId] = {
                        status: mapAttendanceStatus(att.status),
                        note: att.notes || att.note || ''
                    };
                });
                
                // ✅ Map students và điền attendance nếu có
                $scope.students = roster.map(function(enrollment) {
                    var student = enrollment.student || {};
                    var studentId = student.studentId || enrollment.studentId;
                    var existingAtt = attendanceMap[studentId];
                    
                    return {
                        id: studentId,
                        studentId: studentId,
                        studentCode: student.studentCode || enrollment.studentCode || 'N/A',
                        fullName: student.fullName || enrollment.fullName || 'N/A',
                        status: existingAtt ? existingAtt.status : 'present',
                        note: existingAtt ? existingAtt.note : ''
                    };
                });
            })
            .catch(function(error) {
                ToastService.error('Không thể tải danh sách sinh viên');
                $scope.students = [];
            })
            .finally(function() {
                $scope.loadingStudents = false;
            });
    };
    
    // ✅ Map attendance status từ backend (PRESENT, ABSENT, LATE, EXCUSED) sang frontend (present, absent, late, excused)
    function mapAttendanceStatus(backendStatus) {
        if (!backendStatus) return 'present';
        var status = backendStatus.toUpperCase();
        switch(status) {
            case 'PRESENT': return 'present';
            case 'ABSENT': return 'absent';
            case 'LATE': return 'late';
            case 'EXCUSED': return 'excused';
            default: return 'present';
        }
    }
    
    // ✅ Auto-fill form if parameters are provided from URL
    function autoFillFromUrl() {
        if (classIdFromUrl) {
            $scope.selectedClass = classIdFromUrl;
        }
        
        if (periodFromUrl) {
            $scope.period = periodFromUrl;
        }
        
        // Auto-fill date (today) - chỉ được điểm danh hôm nay
        var today = new Date();
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0');
        var day = String(today.getDate()).padStart(2, '0');
        $scope.attendanceDate = year + '-' + month + '-' + day;
        
        // ✅ Set max date = today (chỉ được điểm danh hôm nay)
        $scope.maxAttendanceDate = $scope.attendanceDate;
    }
    
    // ✅ Auto-fill form if parameters are provided
    autoFillFromUrl();
    
    // ✅ Watch attendanceDate để reload attendance khi đổi ngày
    $scope.$watch('attendanceDate', function(newDate, oldDate) {
        if (newDate && newDate !== oldDate && $scope.selectedClass) {
            $scope.loadStudents();
        }
    });
    
    // ✅ Get classId from sessionId if not provided in URL
    function getClassIdFromSessionId() {
        if (!$scope.sessionId || $scope.selectedClass) {
            return Promise.resolve();
        }
        
        // Get lecturer ID first
        var lecturerId = $scope.currentUser && ($scope.currentUser.lecturerId || $scope.currentUser.userId || $scope.currentUser.relatedId);
        if (!lecturerId) {
            return Promise.resolve();
        }
        
        // Get current week
        var today = new Date();
        var iso = getIsoWeek(today);
        
        // Get lecturer's timetable for current week
        return TimetableApi.getLecturerWeek(lecturerId, iso.year, iso.week)
            .then(function(res) {
                var data = (res.data && res.data.data) || [];
                
                // Find session by sessionId
                var session = data.find(function(s) {
                    return (s.session_id || s.sessionId) === $scope.sessionId;
                });
                
                if (session) {
                    var foundClassId = session.class_id || session.classId;
                    
                    if (foundClassId) {
                        $scope.selectedClass = foundClassId;
                        
                        // Also set period if available
                        if (session.period_from && session.period_to && !$scope.period) {
                            $scope.period = session.period_from + '-' + session.period_to;
                        }
                    }
                }
            })
            .catch(function(error) {
                LoggerService.error('Error getting classId from sessionId', error);
            });
    }
    
    // Helper function to get ISO week
    function getIsoWeek(d) {
        var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        var dayNum = date.getUTCDay() || 7;
        date.setUTCDate(date.getUTCDate() + 4 - dayNum);
        var yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
        var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1) / 7);
        return { year: date.getUTCFullYear(), week: weekNo };
    }
    
    // ✅ Initialize maxAttendanceDate = today (chỉ được điểm danh hôm nay)
    var today = new Date();
    var todayStr = today.getFullYear() + '-' + 
                  String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                  String(today.getDate()).padStart(2, '0');
    $scope.maxAttendanceDate = todayStr;
    
    // Load classes on init
    $scope.loadClasses().then(function() {
        // If no classId from URL but have sessionId, try to get it from session
        if (!$scope.selectedClass && $scope.sessionId) {
            getClassIdFromSessionId().then(function() {
                // After getting classId, load students
                if ($scope.selectedClass) {
                    $scope.loadStudents();
                }
            });
        } else if ($scope.selectedClass) {
            $scope.loadStudents();
        }
    });
    
    $scope.markAllPresent = function() {
        $scope.students.forEach(function(student) {
            student.status = 'present';
        });
    };
    
    $scope.getCountByStatus = function(status) {
        return $scope.students.filter(function(student) {
            return student.status === status;
        }).length;
    };
    
    // ✅ Map status từ frontend sang backend
    function mapStatusToBackend(frontendStatus) {
        switch(frontendStatus) {
            case 'present': return 'Present';
            case 'absent': return 'Absent';
            case 'late': return 'Late';
            case 'excused': return 'Excused';
            default: return 'Present';
        }
    }
    
    // ✅ Kiểm tra xem attendance đã tồn tại chưa
    function findExistingAttendance(studentId) {
        if (!$scope.existingAttendances || $scope.existingAttendances.length === 0) {
            return null;
        }
        
        // Tìm attendance record có cùng studentId (đã được filter theo date rồi)
        return $scope.existingAttendances.find(function(att) {
            return (att.studentId || att.student_id) === studentId;
        });
    }
    
    $scope.saveAttendance = function() {
        if (!$scope.selectedClass || !$scope.attendanceDate || !$scope.period) {
            $scope.error = 'Vui lòng chọn đầy đủ thông tin lớp học, ngày và tiết học';
            ToastService.warning('Vui lòng chọn đầy đủ thông tin lớp học, ngày và tiết học');
            return;
        }
        
        if (!$scope.sessionId) {
            $scope.error = 'Không tìm thấy thông tin tiết học';
            ToastService.error('Không tìm thấy thông tin tiết học');
            return;
        }
        
        if (!$scope.students || $scope.students.length === 0) {
            $scope.error = 'Không có sinh viên để điểm danh';
            ToastService.warning('Không có sinh viên để điểm danh');
            return;
        }
        
        // ✅ Validate: Chỉ được điểm danh cho ngày hôm nay
        var today = new Date();
        var todayStr = today.getFullYear() + '-' + 
                      String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                      String(today.getDate()).padStart(2, '0');
        
        if ($scope.attendanceDate !== todayStr) {
            $scope.error = 'Chỉ được điểm danh cho ngày hôm nay (' + todayStr + ')';
            ToastService.error('Chỉ được điểm danh cho ngày hôm nay');
            return;
        }
        
        // ✅ Xác nhận trước khi lưu
        var confirmMessage = 'Bạn có chắc muốn lưu điểm danh cho ' + $scope.students.length + ' sinh viên?';
        if (!confirm(confirmMessage)) {
            return;
        }
        
        $scope.saving = true;
        $scope.error = null;
        $scope.success = null;
        
        // ✅ Load existing attendances để kiểm tra xem cần create hay update
        loadExistingAttendance()
            .then(function(existingAttendances) {
                // ✅ Tạo hoặc cập nhật attendance cho từng sinh viên
                var savePromises = $scope.students.map(function(student) {
                    var existingAtt = findExistingAttendance(student.studentId);
                    
                    if (existingAtt) {
                        // ✅ Update existing attendance
                        var attendanceId = existingAtt.attendanceId || existingAtt.attendance_id;
                        
                        return ApiService.put('/attendances/' + attendanceId, {
                            status: mapStatusToBackend(student.status),
                            notes: student.note || null,
                            updatedBy: $scope.currentUser.username || $scope.currentUser.userId || 'lecturer'
                        });
                    } else {
                        // ✅ Create new attendance
                        var attendanceDate = new Date($scope.attendanceDate);
                        var now = new Date();
                        attendanceDate.setHours(now.getHours());
                        attendanceDate.setMinutes(now.getMinutes());
                        attendanceDate.setSeconds(now.getSeconds());
                        
                        return ApiService.post('/attendances', {
                            studentId: student.studentId,
                            scheduleId: $scope.sessionId,
                            attendanceDate: attendanceDate.toISOString(),
                            status: mapStatusToBackend(student.status),
                            notes: student.note || null,
                            markedBy: $scope.currentUser.username || $scope.currentUser.userId || 'lecturer',
                            createdBy: $scope.currentUser.username || $scope.currentUser.userId || 'lecturer'
                        });
                    }
                });
                
                // ✅ Thực hiện tất cả các requests
                return Promise.all(savePromises);
            })
            .then(function(results) {
                $scope.saving = false;
                $scope.success = 'Lưu điểm danh thành công cho ' + $scope.students.length + ' sinh viên!';
                ToastService.success('Lưu điểm danh thành công!');
                
                // ✅ Reload danh sách attendance để hiển thị dữ liệu mới
                $scope.loadStudents();
                
                // ✅ Emit event để dashboard tự động cập nhật
                $rootScope.$broadcast('attendanceSaved', {
                    sessionId: $scope.sessionId,
                    classId: $scope.selectedClass,
                    date: $scope.attendanceDate
                });
                
                // Clear success message after 5 seconds
                $timeout(function() {
                    $scope.success = null;
                }, 5000);
            })
            .catch(function(error) {
                $scope.saving = false;
                var errorMessage = 'Lỗi khi lưu điểm danh: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                $scope.error = errorMessage;
                ToastService.error(errorMessage);
            });
    };
}]);

