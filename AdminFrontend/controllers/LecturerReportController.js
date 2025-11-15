// Lecturer Report Controller
app.controller('LecturerReportController', ['$scope', 'ReportService', 'SchoolYearService', 'ClassService', 'ToastService', 'LoggerService', 'AuthService',
    function($scope, ReportService, SchoolYearService, ClassService, ToastService, LoggerService, AuthService) {
    
    $scope.loading = false;
    $scope.error = null;
    $scope.currentUser = AuthService.getCurrentUser() || {};
    
    // Filter data
    $scope.filters = {
        schoolYearId: null,
        semester: null,
        classId: null // Administrative class
    };
    
    // Dropdown data
    $scope.schoolYears = [];
    $scope.classes = []; // Administrative classes mà lecturer là chủ nhiệm
    $scope.semesters = [1, 2, 3];
    
    // Report data
    $scope.reports = {
        // 1. Điểm danh sinh viên lớp chủ nhiệm
        attendanceStats: {
            totalStudents: 0,
            averageAttendanceRate: 0,
            goodAttendance: 0, // >= 80%
            poorAttendance: 0, // < 50%
            byStatus: {
                present: 0,
                absent: 0,
                late: 0,
                excused: 0
            }
        },
        // 2. Phân bố GPA sinh viên trong lớp
        gpaDistribution: {
            excellent: 0, // >= 3.5
            good: 0,      // 3.0 - 3.49
            average: 0,   // 2.0 - 2.99
            weak: 0       // < 2.0
        },
        // 3. Tín chỉ còn nợ của sinh viên trong lớp
        creditDebtStats: {
            total: 0,
            averageDebt: 0,
            byRange: [] // [{range: '0-10', count: 5}, ...]
        },
        // 4. Bảng sinh viên điểm danh thấp
        lowAttendanceStudents: []
    };
    
    // Load dropdowns
    $scope.loadDropdowns = function() {
        SchoolYearService.getAll().then(function(res) {
            $scope.schoolYears = (res.data && res.data.data) || res.data || [];
            if ($scope.schoolYears.length > 0 && !$scope.filters.schoolYearId) {
                $scope.filters.schoolYearId = $scope.schoolYears[0].schoolYearId;
            }
        }).catch(function(err) {
            LoggerService.error('Load school years error', err);
        });
        
        // Load administrative classes mà lecturer là chủ nhiệm
        // Note: Cần API để lấy lớp chủ nhiệm của lecturer
        ClassService.getAll().then(function(res) {
            // Filter các lớp mà lecturer là chủ nhiệm
            // Tạm thời load tất cả, sẽ filter ở backend
            $scope.classes = (res.data && res.data.data) || res.data || [];
        }).catch(function(err) {
            LoggerService.error('Load classes error', err);
        });
    };
    
    // Load reports
    $scope.loadReports = function() {
        if (!$scope.filters.classId) {
            ToastService.warning('Vui lòng chọn lớp chủ nhiệm');
            return;
        }
        
        $scope.loading = true;
        $scope.error = null;
        
        ReportService.getLecturerReports($scope.filters).then(function(res) {
            var data = (res.data && res.data.data) || res.data || {};
            
            // Map data to scope
            $scope.reports.attendanceStats = data.attendanceStats || { totalStudents: 0, averageAttendanceRate: 0, goodAttendance: 0, poorAttendance: 0, byStatus: {} };
            $scope.reports.gpaDistribution = data.gpaDistribution || { excellent: 0, good: 0, average: 0, weak: 0 };
            $scope.reports.creditDebtStats = data.creditDebtStats || { total: 0, averageDebt: 0, byRange: [] };
            $scope.reports.lowAttendanceStudents = data.lowAttendanceStudents || [];
            
        }).catch(function(err) {
            $scope.error = 'Lỗi tải thống kê: ' + (err.data && err.data.message) || err.statusText;
            LoggerService.error('Load reports error', err);
        }).finally(function() {
            $scope.loading = false;
        });
    };
    
    // Export to Excel
    $scope.exportExcel = function() {
        try {
            ReportService.exportReport('lecturer', $scope.filters);
            ToastService.success('Đang tải file Excel...');
        } catch (err) {
            ToastService.error('Lỗi export: ' + (err.message || err));
            LoggerService.error('Export error', err);
        }
    };
    
    // Calculate GPA distribution percentages
    $scope.getGpaPercentage = function(category) {
        var total = $scope.reports.gpaDistribution.excellent + 
                   $scope.reports.gpaDistribution.good + 
                   $scope.reports.gpaDistribution.average + 
                   $scope.reports.gpaDistribution.weak;
        if (total === 0) return 0;
        return Math.round(($scope.reports.gpaDistribution[category] / total) * 100);
    };
    
    // Initialize
    $scope.loadDropdowns();
}]);

