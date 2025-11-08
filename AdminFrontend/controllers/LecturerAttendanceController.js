// Lecturer Attendance Controller
app.controller('LecturerAttendanceController', [
    '$scope',
    '$timeout',
    '$q',
    'AuthService',
    'LecturerService',
    'ClassService',
    'EnrollmentService',
    'AttendanceService',
    'ScheduleService',
    'NotificationService',
    'ToastService',
    'LoggerService',
    function(
        $scope,
        $timeout,
        $q,
        AuthService,
        LecturerService,
        ClassService,
        EnrollmentService,
        AttendanceService,
        ScheduleService,
        NotificationService,
        ToastService,
        LoggerService
    ) {
        $scope.currentUser = AuthService.getCurrentUser();
        $scope.lecturerId = ($scope.currentUser && $scope.currentUser.lecturerId) || null;
        $scope.classes = [];
        $scope.selectedClass = '';
        $scope.attendanceDate = new Date().toISOString().split('T')[0];
        $scope.period = '';
        $scope.saving = false;
        $scope.loadingClasses = false;
        $scope.loadingStudents = false;
        $scope.students = [];
        $scope.attendanceMap = {};
        $scope.error = null;
        $scope.success = null;
        $scope.currentSchedule = null; // Lưu schedule hiện tại
        $scope.statusOptions = [
            { value: 'PRESENT', label: 'Có mặt' },
            { value: 'ABSENT', label: 'Vắng mặt' },
            { value: 'LATE', label: 'Đi muộn' },
            { value: 'EXCUSED', label: 'Có phép' }
        ];

        function toDateString(input) {
            if (!input) return '';
            if (typeof input === 'string') return input;
            if (input instanceof Date && !isNaN(input.getTime())) {
                return input.toISOString().split('T')[0];
            }
            if (typeof input === 'object' && input.getFullYear) {
                var year = input.getFullYear();
                var month = input.getMonth() + 1;
                var day = input.getDate();
                month = month < 10 ? '0' + month : month;
                day = day < 10 ? '0' + day : day;
                return year + '-' + month + '-' + day;
            }
            return '';
        }

        function unwrapData(response) {
            if (!response) return [];
            var data = response.data !== undefined ? response.data : response;
            if (data && data.data !== undefined) {
                return data.data || [];
            }
            return data || [];
        }

        function getErrorMessage(error, fallback) {
            if (error && error.data && error.data.message) {
                return error.data.message;
            }
            if (error && error.message) {
                return error.message;
            }
            return fallback;
        }

        function resolveLecturerId() {
            if ($scope.lecturerId) {
                return $q.resolve($scope.lecturerId);
            }

            if (!$scope.currentUser || !$scope.currentUser.userId) {
                $scope.error = 'Không tìm thấy thông tin tài khoản giảng viên.';
                return $q.reject('missing_user');
            }

            return LecturerService.getByUserId($scope.currentUser.userId)
                .then(function(response) {
                    var lecturer = response.data;
                    if (!lecturer || !lecturer.lecturerId) {
                        throw new Error('Không tìm thấy thông tin giảng viên.');
                    }
                    $scope.lecturerId = lecturer.lecturerId;
                    $scope.currentUser.lecturerId = lecturer.lecturerId;
                    AuthService.updateUser($scope.currentUser);
                    return $scope.lecturerId;
                })
                .catch(function(error) {
                    var message = getErrorMessage(error, 'Không thể tải thông tin giảng viên.');
                    $scope.error = message;
                    if (LoggerService && LoggerService.error) {
                        LoggerService.error('Resolve lecturer ID failed', error);
                    }
                    return $q.reject(error);
                });
        }

        function loadClasses() {
            if (!$scope.lecturerId) return;
            $scope.loadingClasses = true;
            $scope.error = null;

            ClassService.getByLecturer($scope.lecturerId)
                .then(function(response) {
                    var items = unwrapData(response);
                    $scope.classes = (items || []).map(function(item) {
                        return {
                            classId: item.classId || item.class_id,
                            classCode: item.classCode || item.class_code,
                            className: item.className || item.class_name,
                            subjectId: item.subjectId || item.subject_id,
                            subjectName: item.subjectName || item.subject_name || item.className,
                            semester: item.semester,
                            academicYearId: item.academicYearId || item.academic_year_id,
                            yearCode: item.yearCode || item.year_code
                        };
                    });
                    if ($scope.classes.length === 0) {
                        $scope.error = 'Bạn chưa được phân công lớp học nào.';
                    }
                })
                .catch(function(error) {
                    var message = getErrorMessage(error, 'Không thể tải danh sách lớp học.');
                    $scope.error = message;
                    if (ToastService && ToastService.error) {
                        ToastService.error(message);
                    }
                    if (LoggerService && LoggerService.error) {
                        LoggerService.error('Load lecturer classes failed', error);
                    }
                })
                .finally(function() {
                    $scope.loadingClasses = false;
                });
        }

        $scope.$watch('attendanceDate', function(newVal, oldVal) {
            var normalized = toDateString(newVal);
            if (normalized && normalized !== newVal) {
                $scope.attendanceDate = normalized;
                return;
            }
            
            // Validate: Không cho phép điểm danh ngày tương lai
            if (normalized) {
                var selectedDate = new Date(normalized);
                var today = new Date();
                today.setHours(0, 0, 0, 0);
                selectedDate.setHours(0, 0, 0, 0);
                
                if (selectedDate > today) {
                    $scope.error = 'Không thể điểm danh cho ngày tương lai. Vui lòng chọn ngày hôm nay hoặc ngày trước đó.';
                    $scope.attendanceDate = today.toISOString().split('T')[0];
                    return;
                }
            }
            
            if (normalized && oldVal && normalized !== oldVal && $scope.selectedClass) {
                $scope.loadScheduleAndStudents();
            }
        }, true);
        
        // Watch for class change
        $scope.$watch('selectedClass', function(newVal, oldVal) {
            if (newVal && newVal !== oldVal) {
                $scope.loadScheduleAndStudents();
            }
        });

        // Load schedule and students
        $scope.loadScheduleAndStudents = function() {
            $scope.loadSchedule().then(function() {
                $scope.loadStudents();
            }).catch(function(error) {
                LoggerService.error('Error loading schedule', error);
                // Continue loading students even if schedule fails
                $scope.loadStudents();
            });
        };
        
        // Load schedule for the selected class and date
        $scope.loadSchedule = function() {
            if (!$scope.selectedClass || !$scope.attendanceDate) {
                $scope.currentSchedule = null;
                return $q.resolve();
            }
            
            var attendanceDate = toDateString($scope.attendanceDate);
            return ScheduleService.getByClassAndDate($scope.selectedClass, attendanceDate)
                .then(function(response) {
                    $scope.currentSchedule = response.data || null;
                    LoggerService.debug('Schedule loaded', { scheduleId: $scope.currentSchedule?.scheduleId });
                })
                .catch(function(error) {
                    LoggerService.error('Error loading schedule', error);
                    $scope.currentSchedule = null;
                });
        };
        
        $scope.loadStudents = function() {
            $scope.success = null;
            $scope.error = null;

            if (!$scope.selectedClass) {
                $scope.students = [];
                $scope.attendanceMap = {};
                return;
            }

            $scope.loadingStudents = true;

            var attendanceDate = toDateString($scope.attendanceDate);
            
            // Validate: Không cho phép điểm danh ngày tương lai
            if (attendanceDate) {
                var selectedDate = new Date(attendanceDate);
                var today = new Date();
                today.setHours(0, 0, 0, 0);
                selectedDate.setHours(0, 0, 0, 0);
                
                if (selectedDate > today) {
                    $scope.error = 'Không thể điểm danh cho ngày tương lai. Vui lòng chọn ngày hôm nay hoặc ngày trước đó.';
                    $scope.loadingStudents = false;
                    return;
                }
            }

            $q.all({
                enrollments: EnrollmentService.getByClass($scope.selectedClass),
                attendance: AttendanceService.getByClass($scope.selectedClass, attendanceDate)
            }).then(function(results) {
                var enrollmentItems = unwrapData(results.enrollments);
                var attendanceItems = unwrapData(results.attendance);

                $scope.attendanceMap = {};
                (attendanceItems || []).forEach(function(att) {
                    var enrollmentId = att.enrollmentId || att.enrollment_id;
                    if (!enrollmentId) return;
                    $scope.attendanceMap[enrollmentId] = {
                        attendanceId: att.attendanceId || att.attendance_id,
                        status: (att.status || 'PRESENT').toUpperCase(),
                        note: att.note || att.notes || ''
                    };
                });

                $scope.students = (enrollmentItems || []).map(function(item, index) {
                    var enrollmentId = item.enrollmentId || item.enrollment_id;
                    var attendance = $scope.attendanceMap[enrollmentId] || null;
                    return {
                        index: index + 1,
                        enrollmentId: enrollmentId,
                        studentId: item.studentId || item.student_id,
                        studentCode: item.studentCode || item.student_code,
                        fullName: item.studentName || item.student_name,
                        status: attendance ? attendance.status : 'PRESENT',
                        attendanceId: attendance ? attendance.attendanceId : null
                    };
                });
                
                // Update allPresent checkbox state
                if ($scope.students.length > 0) {
                    $scope.allPresent = $scope.students.every(function(student) {
                        return student.status === 'PRESENT';
                    });
                }

                if ($scope.students.length === 0) {
                    $scope.error = 'Không tìm thấy sinh viên trong lớp học này.';
                }
            }).catch(function(error) {
                var message = getErrorMessage(error, 'Không thể tải danh sách sinh viên.');
                $scope.error = message;
                if (ToastService && ToastService.error) {
                    ToastService.error(message);
                }
                if (LoggerService && LoggerService.error) {
                    LoggerService.error('Load class roster failed', error);
                }
            }).finally(function() {
                $scope.loadingStudents = false;
            });
        };

        $scope.markAllPresent = function() {
            if ($scope.allPresent) {
                $scope.students.forEach(function(student) {
                    student.status = 'PRESENT';
                });
            }
        };
        
        // Watch for all students being present to update checkbox
        $scope.$watch('students', function(newStudents) {
            if (newStudents && newStudents.length > 0) {
                var allPresent = newStudents.every(function(student) {
                    return student.status === 'PRESENT';
                });
                $scope.allPresent = allPresent;
            }
        }, true);

        $scope.getCountByStatus = function(status) {
            var normalized = (status || '').toUpperCase();
            return $scope.students.filter(function(student) {
                return (student.status || '').toUpperCase() === normalized;
            }).length;
        };

        $scope.saveAttendance = function() {
            if (!$scope.selectedClass) {
                $scope.error = 'Vui lòng chọn lớp học trước khi lưu.';
                return;
            }

            if (!$scope.attendanceDate) {
                $scope.error = 'Vui lòng chọn ngày điểm danh.';
                return;
            }

            if ($scope.students.length === 0) {
                $scope.error = 'Không có sinh viên để lưu điểm danh.';
                return;
            }

            // Validate: Không cho phép điểm danh ngày tương lai
            var attendanceDate = toDateString($scope.attendanceDate);
            if (attendanceDate) {
                var selectedDate = new Date(attendanceDate);
                var today = new Date();
                today.setHours(0, 0, 0, 0);
                selectedDate.setHours(0, 0, 0, 0);
                
                if (selectedDate > today) {
                    $scope.error = 'Không thể điểm danh cho ngày tương lai. Vui lòng chọn ngày hôm nay hoặc ngày trước đó.';
                    return;
                }
            }

            $scope.saving = true;
            $scope.error = null;
            
            var scheduleId = $scope.currentSchedule?.scheduleId || $scope.currentSchedule?.schedule_id || null;
            var absentStudents = []; // Lưu danh sách sinh viên vắng để gửi notification

            var tasks = $scope.students.map(function(student) {
                var status = (student.status || 'PRESENT').toUpperCase();
                
                // Lưu thông tin sinh viên vắng để gửi notification
                if (status === 'ABSENT') {
                    absentStudents.push({
                        studentId: student.studentId,
                        studentCode: student.studentCode,
                        studentName: student.fullName
                    });
                }

                if (student.attendanceId) {
                    return AttendanceService.update(student.attendanceId, {
                        status: status,
                        note: null, // Không cần note
                        updatedBy: $scope.lecturerId
                    });
                }

                return AttendanceService.create({
                    enrollmentId: student.enrollmentId,
                    classId: $scope.selectedClass,
                    attendanceDate: attendanceDate,
                    status: status,
                    note: null, // Không cần note
                    scheduleId: scheduleId, // Thêm ScheduleId
                    createdBy: $scope.lecturerId
                });
            });

            $q.all(tasks).then(function() {
                // Gửi notification cho sinh viên vắng mặt
                if (absentStudents.length > 0) {
                    absentStudents.forEach(function(absentStudent) {
                        var notification = {
                            userId: absentStudent.studentId,
                            type: 'ATTENDANCE_ABSENT',
                            title: 'Thông báo vắng mặt',
                            message: 'Bạn đã vắng mặt trong buổi học ngày ' + $scope.formatDate(attendanceDate) + '. Vui lòng liên hệ giảng viên nếu có lý do chính đáng.',
                            isRead: false
                        };
                        
                        NotificationService.create(notification)
                            .catch(function(error) {
                                LoggerService.error('Error sending notification to student', error);
                            });
                    });
                }
                $scope.success = 'Lưu điểm danh thành công!';
                if (ToastService && ToastService.success) {
                    ToastService.success('Lưu điểm danh thành công!');
                }
                return AttendanceService.getByClass($scope.selectedClass, attendanceDate).then(function(resp) {
                    var attendanceItems = unwrapData(resp);
                    $scope.attendanceMap = {};
                    (attendanceItems || []).forEach(function(att) {
                        var enrollmentId = att.enrollmentId || att.enrollment_id;
                        if (!enrollmentId) return;
                        $scope.attendanceMap[enrollmentId] = {
                            attendanceId: att.attendanceId || att.attendance_id,
                            status: (att.status || 'PRESENT').toUpperCase(),
                            note: att.note || att.notes || ''
                        };
                    });
                    $scope.students.forEach(function(student) {
                        var updated = $scope.attendanceMap[student.enrollmentId];
                        if (updated) {
                            student.attendanceId = updated.attendanceId;
                            student.status = updated.status;
                        }
                    });
                    
                    // Update allPresent checkbox
                    $scope.allPresent = $scope.students.every(function(student) {
                        return student.status === 'PRESENT';
                    });
                });
            }).catch(function(error) {
                var message = getErrorMessage(error, 'Không thể lưu điểm danh.');
                $scope.error = message;
                if (ToastService && ToastService.error) {
                    ToastService.error(message);
                }
                if (LoggerService && LoggerService.error) {
                    LoggerService.error('Save attendance failed', error);
                }
            }).finally(function() {
                $scope.saving = false;
                if ($scope.success) {
                    $timeout(function() {
                        $scope.success = null;
                    }, 3000);
                }
            });
        };

        // Format date helper
        $scope.formatDate = function(dateString) {
            if (!dateString) return '';
            var date = new Date(dateString);
            return date.toLocaleDateString('vi-VN');
        };

        // Initialization
        resolveLecturerId()
            .then(function() {
                loadClasses();
            });
    }
]);

