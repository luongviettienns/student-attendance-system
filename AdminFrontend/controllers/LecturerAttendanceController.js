// Lecturer Attendance Controller
app.controller('LecturerAttendanceController', ['$scope', 'AuthService', function($scope, AuthService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.selectedClass = '';
    $scope.attendanceDate = new Date().toISOString().split('T')[0];
    $scope.period = '';
    $scope.saving = false;
    
    // Demo classes
    $scope.classes = [
        { id: 1, subjectName: 'Lập trình Web', className: 'CNTT K16' },
        { id: 2, subjectName: 'Cơ sở dữ liệu', className: 'CNTT K17' },
        { id: 3, subjectName: 'Kiến trúc máy tính', className: 'CNTT K16' }
    ];
    
    // Demo students
    $scope.students = [];
    
    $scope.loadStudents = function() {
        if (!$scope.selectedClass) {
            $scope.students = [];
            return;
        }
        
        // Demo data
        $scope.students = [
            { id: 1, studentCode: 'SV001', fullName: 'Nguyễn Văn A', status: 'present', note: '' },
            { id: 2, studentCode: 'SV002', fullName: 'Trần Thị B', status: 'present', note: '' },
            { id: 3, studentCode: 'SV003', fullName: 'Lê Văn C', status: 'present', note: '' },
            { id: 4, studentCode: 'SV004', fullName: 'Phạm Thị D', status: 'present', note: '' },
            { id: 5, studentCode: 'SV005', fullName: 'Hoàng Văn E', status: 'present', note: '' },
            { id: 6, studentCode: 'SV006', fullName: 'Vũ Thị F', status: 'present', note: '' },
            { id: 7, studentCode: 'SV007', fullName: 'Đặng Văn G', status: 'present', note: '' },
            { id: 8, studentCode: 'SV008', fullName: 'Bùi Thị H', status: 'present', note: '' }
        ];
    };
    
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
    
    $scope.saveAttendance = function() {
        if (!$scope.selectedClass || !$scope.attendanceDate || !$scope.period) {
            $scope.error = 'Vui lòng chọn đầy đủ thông tin lớp học, ngày và tiết học';
            return;
        }
        
        $scope.saving = true;
        $scope.error = null;
        
        // Simulate API call
        setTimeout(function() {
            $scope.$apply(function() {
                $scope.saving = false;
                $scope.success = 'Lưu điểm danh thành công!';
                
                // Clear success message after 3 seconds
                setTimeout(function() {
                    $scope.$apply(function() {
                        $scope.success = null;
                    });
                }, 3000);
            });
        }, 1000);
    };
}]);

