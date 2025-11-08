// Student Attendance Controller
app.controller('StudentAttendanceController', ['$scope', 'AuthService', 'StudentService', 'ApiService', function($scope, AuthService, StudentService, ApiService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.studentId = null;
    $scope.attendanceRecords = [];
    $scope.loading = false;
    $scope.error = null;
    
    // Load student ID
    function loadStudentId() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.error = 'Không tìm thấy thông tin người dùng.';
            $scope.loading = false;
            return;
        }
        
        $scope.loading = true;
        StudentService.getByUserId($scope.currentUser.userId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.studentId = response.data.data.studentId;
                    if ($scope.studentId) {
                        loadAttendance();
                    } else {
                        $scope.error = 'Không tìm thấy thông tin sinh viên.';
                        $scope.loading = false;
                    }
                } else {
                    $scope.error = 'Không tìm thấy thông tin sinh viên.';
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                if (error.status === 404) {
                    $scope.error = 'Không tìm thấy thông tin sinh viên cho tài khoản này.';
                } else if (error.status === 403) {
                    $scope.error = 'Bạn không có quyền truy cập thông tin sinh viên.';
                } else {
                    $scope.error = 'Không thể tải thông tin sinh viên: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                }
                $scope.loading = false;
            });
    }
    
    // Load attendance records
    function loadAttendance() {
        if (!$scope.studentId) {
            $scope.loading = false;
            return;
        }
        
        $scope.loading = true;
        $scope.error = null;
        
        // Get attendance records by student ID
        ApiService.get('/attendances/student/' + $scope.studentId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.attendanceRecords = response.data.data;
                } else {
                    $scope.attendanceRecords = [];
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                if (error.status === 403) {
                    $scope.error = 'Bạn không có quyền xem điểm danh.';
                } else if (error.status === 404) {
                    $scope.error = 'Không tìm thấy dữ liệu điểm danh cho sinh viên này.';
                } else {
                    $scope.error = 'Không thể tải dữ liệu điểm danh: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                }
                $scope.attendanceRecords = [];
                $scope.loading = false;
            });
    }
    
    // Get status badge
    $scope.getStatusBadge = function(status) {
        switch(status) {
            case 'PRESENT': return 'badge-success';
            case 'ABSENT': return 'badge-danger';
            case 'LATE': return 'badge-warning';
            case 'EXCUSED': return 'badge-info';
            default: return 'badge-secondary';
        }
    };
    
    // Get status text
    $scope.getStatusText = function(status) {
        switch(status) {
            case 'PRESENT': return 'Có mặt';
            case 'ABSENT': return 'Vắng mặt';
            case 'LATE': return 'Đi muộn';
            case 'EXCUSED': return 'Có phép';
            default: return status;
        }
    };
    
    // Initialize
    loadStudentId();
}]);

