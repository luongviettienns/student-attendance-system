// Attendance Management Controller
app.controller('AttendanceController', ['$scope', '$location', '$timeout', 'AttendanceService', 'ClassService', 'StudentService', 'EnrollmentService', 'ImportService', 'ExportService', 'AuthService', 'LoggerService', 'ToastService',
    function($scope, $location, $timeout, AttendanceService, ClassService, StudentService, EnrollmentService, ImportService, ExportService, AuthService, LoggerService, ToastService) {
    
    $scope.attendances = [];
    $scope.displayedAttendances = [];
    $scope.classes = [];
    $scope.students = [];
    $scope.attendance = {};
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // Filters
    $scope.filters = {
        classId: '',
        studentId: '',
        attendanceDate: new Date().toISOString().split('T')[0],
        status: ''
    };
    
    // Import modal
    $scope.showImportModal = false;
    $scope.importData = {
        file: null,
        preview: [],
        errors: [],
        validCount: 0,
        errorCount: 0,
        selectedClass: ''
    };
    
    // Statistics for tạch môn check
    $scope.statistics = {};
    $scope.showStatistics = false;
    
    // Status options
    $scope.statusOptions = [
        { value: 'PRESENT', label: 'Có mặt' },
        { value: 'ABSENT', label: 'Vắng mặt' },
        { value: 'LATE', label: 'Đi muộn' },
        { value: 'EXCUSED', label: 'Có phép' }
    ];
    
    // Get current user
    $scope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    // Logout function
    $scope.logout = function() {
        AuthService.logout();
    };
    
    // Load classes for filter
    $scope.loadClasses = function() {
        ClassService.getAll()
            .then(function(response) {
                var data = response.data?.data || response.data || [];
                $scope.classes = data;
            })
            .catch(function(error) {
                LoggerService.error('Error loading classes', error);
            });
    };
    
    // Load students for filter
    $scope.loadStudents = function() {
        StudentService.getAll({ page: 1, pageSize: 1000 })
            .then(function(response) {
                var data = response.data?.data || response.data || [];
                $scope.students = data;
            })
            .catch(function(error) {
                LoggerService.error('Error loading students', error);
            });
    };
    
    // Load attendances with filters
    $scope.loadAttendances = function() {
        $scope.loading = true;
        $scope.error = null;
        
        var params = {};
        if ($scope.filters.classId) params.classId = $scope.filters.classId;
        if ($scope.filters.studentId) params.studentId = $scope.filters.studentId;
        if ($scope.filters.attendanceDate) params.attendanceDate = $scope.filters.attendanceDate;
        if ($scope.filters.status) params.status = $scope.filters.status;
        
        AttendanceService.getAll(params)
            .then(function(response) {
                var data = response.data?.data || response.data || [];
                $scope.attendances = data;
                $scope.displayedAttendances = data;
                
                // Load statistics if class is selected
                if ($scope.filters.classId) {
                    $scope.loadStatistics();
                }
                
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách điểm danh';
                $scope.loading = false;
                LoggerService.error('Error loading attendances', error);
            });
    };
    
    // Load statistics for tạch môn check
    $scope.loadStatistics = function() {
        if (!$scope.filters.classId) return;
        
        AttendanceService.getStatistics($scope.filters.classId, $scope.filters.studentId)
            .then(function(response) {
                $scope.statistics = response.data?.data || response.data || {};
                $scope.showStatistics = true;
            })
            .catch(function(error) {
                LoggerService.error('Error loading statistics', error);
            });
    };
    
    // Check if student is tạch môn (nghỉ quá 3 buổi)
    $scope.isFailed = function(studentId) {
        if (!$scope.statistics || !$scope.statistics.students) return false;
        var studentStat = $scope.statistics.students.find(function(s) {
            return s.studentId === studentId;
        });
        return studentStat && studentStat.absentCount > 3;
    };
    
    // Filter change handler
    $scope.handleFilterChange = function() {
        $scope.loadAttendances();
    };
    
    // Reset filters
    $scope.resetFilters = function() {
        $scope.filters = {
            classId: '',
            studentId: '',
            attendanceDate: new Date().toISOString().split('T')[0],
            status: ''
        };
        $scope.loadAttendances();
    };
    
    // Load attendance by ID for editing
    $scope.loadAttendance = function(id) {
        $scope.loading = true;
        AttendanceService.getById(id)
            .then(function(response) {
                var data = response.data?.data || response.data || {};
                $scope.attendance = data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin điểm danh';
                $scope.loading = false;
                LoggerService.error('Error loading attendance', error);
            });
    };
    
    // Create or update attendance
    $scope.saveAttendance = function() {
        $scope.error = null;
        $scope.loading = true;
        
        // Validate: Không cho phép điểm danh ngày tương lai
        var attendanceDate = $scope.attendance.attendanceDate || new Date().toISOString().split('T')[0];
        if (attendanceDate) {
            var selectedDate = new Date(attendanceDate);
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            selectedDate.setHours(0, 0, 0, 0);
            
            if (selectedDate > today) {
                $scope.error = 'Không thể điểm danh cho ngày tương lai. Vui lòng chọn ngày hôm nay hoặc ngày trước đó.';
                $scope.loading = false;
                return;
            }
        }
        
        var currentUser = AuthService.getCurrentUser();
        var payload = {
            enrollmentId: $scope.attendance.enrollmentId,
            classId: $scope.attendance.classId,
            attendanceDate: attendanceDate,
            status: $scope.attendance.status || 'PRESENT',
            note: null, // Không cần note
            scheduleId: $scope.attendance.scheduleId || null // Thêm ScheduleId nếu có
        };
        
        if ($scope.isEditMode) {
            payload.updatedBy = currentUser?.userId || currentUser?.username || 'admin';
            AttendanceService.update($scope.attendance.attendanceId, {
                status: payload.status,
                note: null,
                updatedBy: payload.updatedBy
            })
                .then(function(response) {
                    $scope.success = 'Cập nhật điểm danh thành công';
                    $scope.loading = false;
                    $timeout(function() {
                        $scope.cancel();
                        $scope.loadAttendances();
                    }, 1500);
                })
                .catch(function(error) {
                    $scope.error = error.data?.message || 'Không thể cập nhật điểm danh';
                    $scope.loading = false;
                    LoggerService.error('Error updating attendance', error);
                });
        } else {
            payload.createdBy = currentUser?.userId || currentUser?.username || 'admin';
            AttendanceService.create(payload)
                .then(function(response) {
                    $scope.success = 'Tạo điểm danh thành công';
                    $scope.loading = false;
                    $timeout(function() {
                        $scope.cancel();
                        $scope.loadAttendances();
                    }, 1500);
                })
                .catch(function(error) {
                    $scope.error = error.data?.message || 'Không thể tạo điểm danh';
                    $scope.loading = false;
                    LoggerService.error('Error creating attendance', error);
                });
        }
    };
    
    // Delete attendance
    $scope.deleteAttendance = function(attendanceId) {
        if (!confirm('Bạn có chắc chắn muốn xóa bản ghi điểm danh này?')) {
            return;
        }
        
        var currentUser = AuthService.getCurrentUser();
        var deletedBy = currentUser?.userId || currentUser?.username || 'admin';
        
        AttendanceService.delete(attendanceId, deletedBy)
            .then(function(response) {
                ToastService.success('Xóa điểm danh thành công');
                $scope.loadAttendances();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa điểm danh');
                LoggerService.error('Error deleting attendance', error);
            });
    };
    
    // Open import modal
    $scope.openImportModal = function() {
        $scope.showImportModal = true;
        $scope.importData = {
            file: null,
            preview: [],
            errors: [],
            validCount: 0,
            errorCount: 0,
            selectedClass: ''
        };
    };
    
    // Close import modal
    $scope.closeImportModal = function() {
        $scope.showImportModal = false;
    };
    
    // Download import template
    $scope.downloadTemplate = function() {
        var columns = [
            { 
                label: 'Mã SV', 
                example: 'SV2024001',
                required: true,
                note: 'Mã sinh viên (bắt buộc)'
            },
            { 
                label: 'Ngày điểm danh', 
                example: '2024-10-15',
                required: true,
                note: 'Định dạng: YYYY-MM-DD'
            },
            { 
                label: 'Trạng thái', 
                example: 'PRESENT',
                required: true,
                note: 'PRESENT (Có mặt), ABSENT (Vắng), LATE (Muộn), EXCUSED (Có phép)'
            }
        ];
        
        ImportService.downloadTemplate('MauNhapDiemDanh', columns);
    };
    
    // Handle file selection
    $scope.onFileSelect = function(files) {
        if (files && files.length > 0) {
            $scope.importData.file = files[0];
            $scope.processImportFile();
        }
    };
    
    // Process import file
    $scope.processImportFile = function() {
        if (!$scope.importData.selectedClass) {
            $scope.error = 'Vui lòng chọn lớp học trước khi import';
            return;
        }
        
        ImportService.readFile($scope.importData.file)
            .then(function(data) {
                // Validate data
                var schema = [
                    { 
                        name: 'Mã SV', 
                        label: 'Mã SV', 
                        required: true 
                    },
                    { 
                        name: 'Ngày điểm danh', 
                        label: 'Ngày điểm danh', 
                        required: true,
                        type: 'date'
                    },
                    { 
                        name: 'Trạng thái', 
                        label: 'Trạng thái', 
                        required: true,
                        validate: function(value) {
                            var validStatuses = ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'];
                            if (!validStatuses.includes(value.toUpperCase())) {
                                return 'Trạng thái phải là: PRESENT, ABSENT, LATE, hoặc EXCUSED';
                            }
                        }
                    }
                ];
                
                var result = ImportService.validate(data, schema);
                
                $scope.importData.preview = result.valid;
                $scope.importData.errors = result.invalid;
                $scope.importData.validCount = result.valid.length;
                $scope.importData.errorCount = result.invalid.length;
            })
            .catch(function(error) {
                $scope.error = error;
            });
    };
    
    // Confirm and import data
    $scope.confirmImport = function() {
        if ($scope.importData.validCount === 0) {
            $scope.error = 'Không có dữ liệu hợp lệ để import';
            return;
        }
        
        if (!$scope.importData.selectedClass) {
            $scope.error = 'Vui lòng chọn lớp học';
            return;
        }
        
        $scope.loading = true;
        $scope.error = null;
        
        var currentUser = AuthService.getCurrentUser();
        var createdBy = currentUser?.userId || currentUser?.username || 'admin';
        
        // Step 1: Get enrollments for the class to map student codes to enrollment IDs
        EnrollmentService.getByClass($scope.importData.selectedClass)
            .then(function(enrollmentResponse) {
                var enrollments = enrollmentResponse.data?.data || enrollmentResponse.data || [];
                
                // Create a map: studentCode -> enrollmentId
                var enrollmentMap = {};
                enrollments.forEach(function(enrollment) {
                    var studentCode = enrollment.studentCode || enrollment.student_code;
                    if (studentCode) {
                        enrollmentMap[studentCode] = enrollment.enrollmentId || enrollment.enrollment_id;
                    }
                });
                
                // Step 2: Transform import data to attendance records
                var attendanceRecords = [];
                var errors = [];
                
                $scope.importData.preview.forEach(function(row, index) {
                    var studentCode = row['Mã SV'];
                    var enrollmentId = enrollmentMap[studentCode];
                    
                    if (!enrollmentId) {
                        errors.push({
                            rowNumber: index + 2, // +2 because Excel has header row and 0-indexed
                            errorMessage: 'Không tìm thấy enrollment cho sinh viên: ' + studentCode
                        });
                        return;
                    }
                    
                    // Parse date
                    var attendanceDate = row['Ngày điểm danh'];
                    if (typeof attendanceDate === 'string') {
                        // Try to parse date string
                        attendanceDate = new Date(attendanceDate);
                    }
                    
                    attendanceRecords.push({
                        enrollmentId: enrollmentId,
                        classId: $scope.importData.selectedClass,
                        attendanceDate: attendanceDate ? attendanceDate.toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
                        status: (row['Trạng thái'] || 'PRESENT').toUpperCase(),
                        note: null, // Không cần note
                        createdBy: createdBy
                    });
                });
                
                if (attendanceRecords.length === 0) {
                    $scope.error = 'Không có bản ghi hợp lệ để import. Vui lòng kiểm tra lại mã sinh viên.';
                    $scope.loading = false;
                    return;
                }
                
                // Step 3: Batch create attendance records
                AttendanceService.createBatch(attendanceRecords)
                    .then(function(response) {
                        var result = response.data?.data || response.data || {};
                        
                        var totalErrors = (errors.length || 0) + (result.errorCount || 0);
                        var totalSuccess = result.successCount || attendanceRecords.length;
                        
                        if (totalErrors > 0) {
                            var errorMessages = errors.map(function(err) {
                                return 'Dòng ' + err.rowNumber + ': ' + err.errorMessage;
                            });
                            
                            if (result.errors) {
                                result.errors.forEach(function(err) {
                                    errorMessages.push('Enrollment ' + err.enrollmentId + ': ' + err.errorMessage);
                                });
                            }
                            
                            $scope.error = 'Import thành công ' + totalSuccess + '/' + $scope.importData.validCount + ' bản ghi.\n\n' +
                                           'Có ' + totalErrors + ' lỗi:\n' + errorMessages.join('\n');
                        } else {
                            $scope.success = 'Import thành công ' + totalSuccess + ' bản ghi! 🎉';
                            ToastService.success('Import thành công ' + totalSuccess + ' bản ghi!');
                        }
                        
                        $scope.loading = false;
                        $scope.closeImportModal();
                        $scope.loadAttendances();
                    })
                    .catch(function(error) {
                        $scope.error = 'Lỗi khi import: ' + (error.data?.message || error.message || 'Vui lòng thử lại');
                        $scope.loading = false;
                        LoggerService.error('Error importing attendance', error);
                        ToastService.error('Lỗi khi import điểm danh');
                    });
            })
            .catch(function(error) {
                $scope.error = 'Lỗi khi tải danh sách đăng ký: ' + (error.data?.message || error.message || 'Vui lòng thử lại');
                $scope.loading = false;
                LoggerService.error('Error loading enrollments for import', error);
                ToastService.error('Không thể tải danh sách đăng ký của lớp học');
            });
    };
    
    // Export to Excel
    $scope.exportToExcel = function() {
        var columns = [
            { label: 'Mã SV', field: 'studentCode' },
            { label: 'Họ tên', field: 'studentName' },
            { label: 'Lớp', field: 'className' },
            { label: 'Môn học', field: 'subjectName' },
            { label: 'Ngày điểm danh', field: 'attendanceDate', type: 'date' },
            { label: 'Trạng thái', field: 'status' }
        ];
        
        var exportOptions = {
            title: '📋 DANH SÁCH ĐIỂM DANH',
            info: [
                ['Đơn vị:', 'Trường Đại học ABC'],
                ['Thời gian xuất:', new Date().toLocaleDateString('vi-VN') + ' ' + new Date().toLocaleTimeString('vi-VN')],
                ['Người xuất:', $scope.getCurrentUser() ? $scope.getCurrentUser().fullName : 'Admin']
            ],
            sheetName: 'Điểm danh',
            showSummary: true
        };
        
        ExportService.exportToExcel($scope.displayedAttendances, 'DanhSachDiemDanh', columns, exportOptions);
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $scope.attendance = {
            attendanceDate: new Date().toISOString().split('T')[0],
            status: 'PRESENT'
        };
        $scope.isEditMode = false;
    };
    
    $scope.goToEdit = function(attendanceId) {
        $scope.loadAttendance(attendanceId);
    };
    
    $scope.cancel = function() {
        $scope.attendance = {};
        $scope.isEditMode = false;
    };
    
    // Format status label
    $scope.getStatusLabel = function(status) {
        var option = $scope.statusOptions.find(function(opt) {
            return opt.value === status;
        });
        return option ? option.label : status;
    };
    
    // Format date
    $scope.formatDate = function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        return date.toLocaleDateString('vi-VN');
    };
    
    // Initialize
    $scope.loadClasses();
    $scope.loadStudents();
    $scope.loadAttendances();
}]);

