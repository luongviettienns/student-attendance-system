// Student Grades Controller
app.controller('StudentGradesController', [
    '$scope', 'AuthService', 'GradeService', 'SchoolYearService', 'StudentService',
    function($scope, AuthService, GradeService, SchoolYearService, StudentService) {
    
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.schoolYears = [];
    $scope.selectedSchoolYear = null;
    $scope.selectedSemester = null;
    $scope.grades = [];
    $scope.summary = {
        currentGPA: 0,
        cumulativeGPA: 0,
        totalCredits: 0,
        requiredCredits: 120,
        rank: 'Chưa có'
    };
    $scope.loading = false;
    $scope.error = null;
    $scope.studentId = null;
    
    // Get student ID from user ID
    $scope.loadStudentId = function() {
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            $scope.error = 'Không tìm thấy thông tin người dùng';
            $scope.loading = false;
            return;
        }
        
        StudentService.getByUserId($scope.currentUser.userId).then(function(response) {
            if (response.data && response.data.data) {
                $scope.studentId = response.data.data.studentId;
                $scope.loadSchoolYears();
            } else {
                $scope.error = 'Không tìm thấy thông tin sinh viên';
                $scope.loading = false;
            }
        }).catch(function(error) {
            $scope.error = 'Không thể tải thông tin sinh viên';
            $scope.loading = false;
        });
    };
    
    // Load available school years
    $scope.loadSchoolYears = function() {
        SchoolYearService.getAll().then(function(response) {
            if (response.data) {
                $scope.schoolYears = response.data;
                // Auto-select current school year
                var current = $scope.schoolYears.find(function(sy) { return sy.isActive; });
                if (current) {
                    $scope.selectedSchoolYear = current.schoolYearId;
                    if (current.currentSemester) {
                        $scope.selectedSemester = current.currentSemester.toString();
                    }
                    $scope.loadGrades();
                }
            }
        }).catch(function(error) {
            $scope.error = 'Không thể tải danh sách năm học';
        });
    };
    
    // Load grades by school year + semester
    $scope.loadGrades = function() {
        if (!$scope.selectedSchoolYear || !$scope.studentId) return;
        
        $scope.loading = true;
        $scope.error = null;
        
        GradeService.getByStudentSchoolYear(
            $scope.studentId, 
            $scope.selectedSchoolYear, 
            $scope.selectedSemester
        ).then(function(response) {
            if (response.data) {
                $scope.grades = response.data;
            } else {
                $scope.grades = [];
            }
            // Load summary
            return GradeService.getGradeSummary(
                $scope.studentId, 
                $scope.selectedSchoolYear, 
                $scope.selectedSemester
            );
        }).then(function(response) {
            if (response.data) {
                $scope.summary = {
                    currentGPA: response.data.gpa10 || 0,
                    cumulativeGPA: response.data.gpa10 || 0, // TODO: Calculate cumulative
                    totalCredits: response.data.totalCredits || 0,
                    requiredCredits: 120, // TODO: Get from student profile
                    rank: response.data.rankText || 'Chưa có'
                };
            }
            $scope.loading = false;
        }).catch(function(error) {
            $scope.error = 'Không thể tải điểm';
            $scope.grades = [];
            $scope.loading = false;
        });
    };
    
    // Filter change handler
    $scope.onFilterChange = function() {
        $scope.loadGrades();
    };
    
    // Initialize
    $scope.loadStudentId();
}]);
