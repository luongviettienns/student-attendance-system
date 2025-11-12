// Enrollment Controller
app.controller('EnrollmentController', [
    '$scope', '$routeParams', 'EnrollmentService', 'StudentService', 'ClassService', 
    'RegistrationPeriodService', 'ToastService', 'AuthService',
    function($scope, $routeParams, EnrollmentService, StudentService, ClassService, 
             RegistrationPeriodService, ToastService, AuthService) {
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.enrollments = [];
    $scope.availableClasses = [];
    $scope.summary = null;
    $scope.activePeriod = null;
    $scope.currentStudent = null;
    $scope.loading = false;
    
    $scope.filters = {
        studentId: '',
        classId: '',
        status: ''
    };
    
    // Get current user
    $scope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    $scope.isAdmin = function() {
        const user = $scope.getCurrentUser();
        return user && (user.roleName === 'Admin' || user.roleName === 'SuperAdmin');
    };
    
    $scope.isStudent = function() {
        const user = $scope.getCurrentUser();
        return user && user.roleName === 'Student';
    };
    
    // ============================================================
    // LOAD DATA
    // ============================================================
    $scope.loadEnrollments = function() {
        $scope.loading = true;
        
        let promise;
        if ($scope.filters.studentId) {
            promise = EnrollmentService.getByStudent($scope.filters.studentId);
        } else if ($scope.filters.classId) {
            promise = EnrollmentService.getByClass($scope.filters.classId);
        } else {
            promise = EnrollmentService.getAll();
        }
        
        promise.then(function(response) {
            if (response.data.success) {
                $scope.enrollments = response.data.data;
            }
            $scope.loading = false;
        }).catch(function(error) {
            ToastService.error('Không thể tải danh sách đăng ký');
            $scope.loading = false;
        });
    };
    
    $scope.loadMyEnrollments = function() {
        const user = $scope.getCurrentUser();
        if (user && user.relatedId) {
            $scope.filters.studentId = user.relatedId;
            $scope.loadEnrollments();
            $scope.loadSummary(user.relatedId);
            $scope.loadAvailableClasses(user.relatedId);
        }
    };
    
    $scope.loadAvailableClasses = function(studentId, semester, academicYearId) {
        EnrollmentService.getAvailableClasses(studentId, semester, academicYearId)
            .then(function(response) {
                if (response.data.success) {
                    $scope.availableClasses = response.data.data;
                }
            });
    };
    
    $scope.loadSummary = function(studentId, semester, academicYearId) {
        EnrollmentService.getSummary(studentId, semester, academicYearId)
            .then(function(response) {
                if (response.data.success) {
                    $scope.summary = response.data.data;
                }
            });
    };
    
    $scope.loadActivePeriod = function() {
        RegistrationPeriodService.getActive().then(function(response) {
            if (response.data.success) {
                $scope.activePeriod = response.data.data;
            }
        }).catch(function() {
            $scope.activePeriod = null;
        });
    };
    
    // ============================================================
    // REGISTER
    // ============================================================
    $scope.showRegisterModal = function() {
        const user = $scope.getCurrentUser();
        $scope.currentEnrollment = {
            studentId: user.relatedId,
            classId: '',
            notes: ''
        };
        $('#registerModal').modal('show');
    };
    
    $scope.register = function() {
        if (!$scope.currentEnrollment) return;
        
        if (!$scope.activePeriod) {
            ToastService.error('Không có đợt đăng ký nào đang mở');
            return;
        }
        
        EnrollmentService.register(
            $scope.currentEnrollment.studentId,
            $scope.currentEnrollment.classId,
            $scope.currentEnrollment.notes
        ).then(function(response) {
            if (response.data.success) {
                ToastService.success('Đăng ký học phần thành công');
                $('#registerModal').modal('hide');
                $scope.loadMyEnrollments();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể đăng ký học phần');
        });
    };
    
    // ============================================================
    // APPROVE (Admin)
    // ============================================================
    $scope.approve = function(enrollmentId) {
        if (!confirm('Bạn có chắc chắn muốn phê duyệt đăng ký này?')) return;
        
        EnrollmentService.approve(enrollmentId).then(function(response) {
            if (response.data.success) {
                ToastService.success('Phê duyệt đăng ký thành công');
                $scope.loadEnrollments();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể phê duyệt');
        });
    };
    
    // ============================================================
    // DROP (Student)
    // ============================================================
    $scope.showDropModal = function(enrollment) {
        $scope.currentEnrollment = enrollment;
        $scope.dropReason = '';
        $('#dropModal').modal('show');
    };
    
    $scope.drop = function() {
        if (!$scope.dropReason) {
            ToastService.error('Vui lòng nhập lý do hủy đăng ký');
            return;
        }
        
        EnrollmentService.drop($scope.currentEnrollment.enrollmentId, $scope.dropReason)
            .then(function(response) {
                if (response.data.success) {
                    ToastService.success('Hủy đăng ký học phần thành công');
                    $('#dropModal').modal('hide');
                    $scope.loadMyEnrollments();
                }
            }).catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể hủy đăng ký');
            });
    };
    
    // ============================================================
    // WITHDRAW (Admin)
    // ============================================================
    $scope.showWithdrawModal = function(enrollment) {
        $scope.currentEnrollment = enrollment;
        $scope.withdrawReason = '';
        $('#withdrawModal').modal('show');
    };
    
    $scope.withdraw = function() {
        if (!$scope.withdrawReason) {
            ToastService.error('Vui lòng nhập lý do rút học phần');
            return;
        }
        
        EnrollmentService.withdraw($scope.currentEnrollment.enrollmentId, $scope.withdrawReason)
            .then(function(response) {
                if (response.data.success) {
                    ToastService.success('Rút học phần thành công');
                    $('#withdrawModal').modal('hide');
                    $scope.loadEnrollments();
                }
            }).catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể rút học phần');
            });
    };
    
    // ============================================================
    // UI HELPERS
    // ============================================================
    $scope.getStatusBadge = function(status) {
        switch(status) {
            case 'APPROVED': return 'badge-success';
            case 'PENDING': return 'badge-warning';
            case 'DROPPED': return 'badge-danger';
            case 'WITHDRAWN': return 'badge-secondary';
            default: return 'badge-info';
        }
    };
    
    $scope.canDrop = function(enrollment) {
        if (enrollment.enrollmentStatus !== 'APPROVED') return false;
        if (!enrollment.dropDeadline) return false;
        return new Date() <= new Date(enrollment.dropDeadline);
    };
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.init = function() {
        $scope.loadActivePeriod();
        
        if ($scope.isStudent()) {
            $scope.loadMyEnrollments();
        } else {
            $scope.loadEnrollments();
        }
    };
    
    $scope.init();
}]);

