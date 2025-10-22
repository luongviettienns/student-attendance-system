// Lecturer Grades Controller
app.controller('LecturerGradesController', ['$scope', 'AuthService', function($scope, AuthService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.selectedClass = '';
    $scope.gradeType = '';
    $scope.saving = false;
    
    var gradeTypeNames = {
        'attendance': 'Chuyên cần',
        'midterm': 'Giữa kỳ',
        'assignment': 'Bài tập',
        'final': 'Cuối kỳ'
    };
    
    $scope.$watch('gradeType', function(newVal) {
        $scope.gradeTypeName = gradeTypeNames[newVal] || '';
    });
    
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
        
        // Demo data with random grades
        $scope.students = [
            { id: 1, studentCode: 'SV001', fullName: 'Nguyễn Văn A', grade: null, note: '' },
            { id: 2, studentCode: 'SV002', fullName: 'Trần Thị B', grade: null, note: '' },
            { id: 3, studentCode: 'SV003', fullName: 'Lê Văn C', grade: null, note: '' },
            { id: 4, studentCode: 'SV004', fullName: 'Phạm Thị D', grade: null, note: '' },
            { id: 5, studentCode: 'SV005', fullName: 'Hoàng Văn E', grade: null, note: '' },
            { id: 6, studentCode: 'SV006', fullName: 'Vũ Thị F', grade: null, note: '' },
            { id: 7, studentCode: 'SV007', fullName: 'Đặng Văn G', grade: null, note: '' },
            { id: 8, studentCode: 'SV008', fullName: 'Bùi Thị H', grade: null, note: '' }
        ];
    };
    
    $scope.getAverageGrade = function() {
        var validGrades = $scope.students.filter(function(s) {
            return s.grade !== null && s.grade !== undefined && s.grade !== '';
        });
        
        if (validGrades.length === 0) return 0;
        
        var sum = validGrades.reduce(function(acc, s) {
            return acc + parseFloat(s.grade);
        }, 0);
        
        return sum / validGrades.length;
    };
    
    $scope.getCountByRange = function(min, max) {
        return $scope.students.filter(function(s) {
            var grade = parseFloat(s.grade);
            return !isNaN(grade) && grade >= min && grade <= max;
        }).length;
    };
    
    $scope.saveGrades = function() {
        if (!$scope.selectedClass || !$scope.gradeType) {
            $scope.error = 'Vui lòng chọn đầy đủ thông tin lớp học và loại điểm';
            return;
        }
        
        // Validate grades
        var invalidGrades = $scope.students.filter(function(s) {
            var grade = parseFloat(s.grade);
            return s.grade !== null && s.grade !== undefined && s.grade !== '' && (isNaN(grade) || grade < 0 || grade > 10);
        });
        
        if (invalidGrades.length > 0) {
            $scope.error = 'Có điểm không hợp lệ. Điểm phải từ 0 đến 10';
            return;
        }
        
        $scope.saving = true;
        $scope.error = null;
        
        // Simulate API call
        setTimeout(function() {
            $scope.$apply(function() {
                $scope.saving = false;
                $scope.success = 'Lưu điểm thành công!';
                
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

