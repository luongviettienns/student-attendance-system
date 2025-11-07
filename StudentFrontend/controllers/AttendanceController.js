// Student Attendance Controller
app.controller('AttendanceController', ['$scope', 'AuthService', 'StudentService', 'ApiService', function($scope, AuthService, StudentService, ApiService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.studentId = null;
    $scope.attendanceRecords = [];
    $scope.loading = false;
    $scope.error = null;
    
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
                    loadAttendance();
                } else {
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                console.error('Error loading student info:', error);
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
        
        // TODO: Replace with actual attendance API endpoint
        ApiService.get('/attendance/student/' + $scope.studentId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.attendanceRecords = response.data.data;
                } else {
                    $scope.attendanceRecords = [];
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading attendance:', error);
                $scope.error = 'Không thể tải dữ liệu điểm danh';
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


