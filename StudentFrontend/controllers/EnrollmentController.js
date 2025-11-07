// Enrollment Controller for Students
app.controller('EnrollmentController', ['$scope', 'AuthService', 'EnrollmentService', 'StudentService', 'ToastService', function($scope, AuthService, EnrollmentService, StudentService, ToastService) {
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.studentId = null;
    $scope.enrollments = [];
    $scope.availableClasses = [];
    $scope.summary = null;
    $scope.activePeriod = null;
    $scope.loading = false;
    $scope.currentEnrollment = {};
    $scope.dropReason = '';
    
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
                    loadData();
                } else {
                    $scope.loading = false;
                }
            })
            .catch(function(error) {
                console.error('Error loading student info:', error);
                $scope.loading = false;
            });
    }
    
    // Load enrollment data
    function loadData() {
        if (!$scope.studentId) {
            $scope.loading = false;
            return;
        }
        
        $scope.loading = true;
        
        // Load enrollments
        EnrollmentService.getByStudent($scope.studentId)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.enrollments = response.data.data;
                } else {
                    $scope.enrollments = [];
                }
                
                // Load summary
                return EnrollmentService.getSummary($scope.studentId);
            })
            .then(function(response) {
                if (response.data) {
                    $scope.summary = response.data;
                }
                
                // Load available classes
                return EnrollmentService.getAvailableClasses($scope.studentId);
            })
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.availableClasses = response.data.data;
                } else {
                    $scope.availableClasses = [];
                }
                
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading enrollment data:', error);
                ToastService.error('Không thể tải dữ liệu đăng ký');
                $scope.loading = false;
            });
    }
    
    // Show register modal
    $scope.showRegisterModal = function() {
        $('#registerModal').modal('show');
        $scope.currentEnrollment = { classId: null, notes: '' };
    };
    
    // Register for a class
    $scope.register = function() {
        if (!$scope.currentEnrollment.classId) {
            ToastService.warning('Vui lòng chọn lớp học phần');
            return;
        }
        
        EnrollmentService.register($scope.studentId, $scope.currentEnrollment.classId, $scope.currentEnrollment.notes)
            .then(function(response) {
                ToastService.success('Đăng ký thành công!');
                $('#registerModal').modal('hide');
                loadData();
            })
            .catch(function(error) {
                var errorMsg = 'Không thể đăng ký';
                if (error.data && error.data.message) {
                    errorMsg = error.data.message;
                }
                ToastService.error(errorMsg);
            });
    };
    
    // Quick register
    $scope.quickRegister = function(classId) {
        $scope.currentEnrollment = { classId: classId, notes: '' };
        $scope.register();
    };
    
    // Show drop modal
    $scope.showDropModal = function(enrollment) {
        $scope.currentEnrollment = enrollment;
        $scope.dropReason = '';
        $('#dropModal').modal('show');
    };
    
    // Drop enrollment
    $scope.drop = function() {
        if (!$scope.dropReason) {
            ToastService.warning('Vui lòng nhập lý do hủy');
            return;
        }
        
        EnrollmentService.drop($scope.currentEnrollment.enrollmentId, $scope.dropReason)
            .then(function(response) {
                ToastService.success('Hủy đăng ký thành công!');
                $('#dropModal').modal('hide');
                loadData();
            })
            .catch(function(error) {
                var errorMsg = 'Không thể hủy đăng ký';
                if (error.data && error.data.message) {
                    errorMsg = error.data.message;
                }
                ToastService.error(errorMsg);
            });
    };
    
    // Check if can drop
    $scope.canDrop = function(enrollment) {
        if (!enrollment) return false;
        if (enrollment.enrollmentStatus !== 'APPROVED' && enrollment.enrollmentStatus !== 'PENDING') {
            return false;
        }
        if (enrollment.dropDeadline) {
            var deadline = new Date(enrollment.dropDeadline);
            return new Date() <= deadline;
        }
        return true;
    };
    
    // Get status badge class
    $scope.getStatusBadge = function(status) {
        switch(status) {
            case 'APPROVED': return 'badge-success';
            case 'PENDING': return 'badge-warning';
            case 'DROPPED': return 'badge-danger';
            case 'WITHDRAWN': return 'badge-secondary';
            default: return 'badge-secondary';
        }
    };
    
    // Initialize
    loadStudentId();
}]);


