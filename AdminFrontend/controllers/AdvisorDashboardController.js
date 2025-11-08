// Advisor Dashboard Controller
app.controller('AdvisorDashboardController', ['$scope', '$location', 'AuthService', 'AvatarService', 'AdvisorService', 'ToastService', function($scope, $location, AuthService, AvatarService, AdvisorService, ToastService) {
    $scope.currentUser = AuthService.getCurrentUser();
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Initialize stats
    $scope.stats = {
        totalStudents: 0,
        warningAttendanceStudents: 0,
        lowGpaStudents: 0,
        excellentStudents: 0,
        averageAttendanceRate: 0,
        averagePassRate: 0,
        averageGpa: 0
    };
    
    // Warning students
    $scope.warningStudents = [];
    $scope.warningStudentsPagination = {
        page: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0
    };
    
    // Loading and error states
    $scope.loadingStats = true;
    $scope.loadingWarningStudents = true;
    $scope.errorStats = null;
    $scope.errorWarningStudents = null;
    
    // Demo recent consultations (can be replaced with API later)
    $scope.recentConsultations = [
        {
            studentName: 'Nguyễn Văn A',
            date: '21/10/2025 14:30',
            content: 'Tư vấn về việc cải thiện điểm chuyên cần và kế hoạch học tập'
        },
        {
            studentName: 'Trần Thị B',
            date: '20/10/2025 10:15',
            content: 'Hướng dẫn đăng ký học phần và lựa chọn môn tự chọn'
        },
        {
            studentName: 'Lê Văn C',
            date: '19/10/2025 16:00',
            content: 'Tư vấn về khó khăn trong học tập và phương pháp cải thiện'
        }
    ];
    
    // Load dashboard stats
    $scope.loadDashboardStats = function() {
        $scope.loadingStats = true;
        $scope.errorStats = null;
        
        AdvisorService.getDashboardStats(null, false).then(function(stats) {
            $scope.stats = {
                totalStudents: stats.totalStudents || 0,
                warningAttendanceStudents: stats.warningAttendanceStudents || 0,
                lowGpaStudents: stats.lowGpaStudents || 0,
                excellentStudents: stats.excellentStudents || 0,
                averageAttendanceRate: stats.averageAttendanceRate || 0,
                averagePassRate: stats.averagePassRate || 0,
                averageGpa: stats.averageGpa || 0
            };
            $scope.loadingStats = false;
        }).catch(function(error) {
            console.error('Error loading dashboard stats:', error);
            $scope.errorStats = error.data?.message || 'Lỗi khi tải thống kê';
            $scope.loadingStats = false;
            ToastService.error('Lỗi khi tải thống kê dashboard');
        });
    };
    
    // Load warning students
    $scope.loadWarningStudents = function(page) {
        if (page) {
            $scope.warningStudentsPagination.page = page;
        }
        
        $scope.loadingWarningStudents = true;
        $scope.errorWarningStudents = null;
        
        var params = {
            page: $scope.warningStudentsPagination.page,
            pageSize: $scope.warningStudentsPagination.pageSize
        };
        
        AdvisorService.getWarningStudents(params, false).then(function(response) {
            $scope.warningStudents = response.data || [];
            $scope.warningStudentsPagination = {
                page: response.pagination?.page || 1,
                pageSize: response.pagination?.pageSize || 20,
                totalCount: response.pagination?.totalCount || 0,
                totalPages: response.pagination?.totalPages || 0
            };
            $scope.loadingWarningStudents = false;
        }).catch(function(error) {
            console.error('Error loading warning students:', error);
            $scope.errorWarningStudents = error.data?.message || 'Lỗi khi tải danh sách sinh viên cảnh báo';
            $scope.loadingWarningStudents = false;
            ToastService.error('Lỗi khi tải danh sách sinh viên cảnh báo');
        });
    };
    
    // Refresh all data
    $scope.refreshData = function() {
        $scope.loadDashboardStats();
        $scope.loadWarningStudents();
    };
    
    // View student detail
    $scope.viewStudentDetail = function(studentId) {
        // Navigate to student detail page
        $location.path('/advisor/students/' + studentId);
    };
    
    // Contact student
    $scope.contactStudent = function(student) {
        // TODO: Implement contact student functionality
        alert('Gửi email liên hệ đến sinh viên: ' + student.fullName);
    };
    
    // Get absence rate (100 - attendance rate)
    $scope.getAbsenceRate = function(student) {
        if (!student.attendanceRate && student.attendanceRate !== 0) {
            return 0;
        }
        return Math.max(0, 100 - student.attendanceRate);
    };
    
    // Initialize on load
    $scope.loadDashboardStats();
    $scope.loadWarningStudents();
}]);

