// Registration Period Controller
app.controller('RegistrationPeriodController', [
    '$scope', 'RegistrationPeriodService', 'AcademicYearService', 'ToastService', 'AuthService',
    function($scope, RegistrationPeriodService, AcademicYearService, ToastService, AuthService) {
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.periods = [];
    $scope.activePeriod = null;
    $scope.currentPeriod = null;
    $scope.academicYears = [];
    $scope.loading = false;
    
    // Check authorization
    $scope.isAdmin = function() {
        const user = AuthService.getCurrentUser();
        return user && (user.roleName === 'Admin' || user.roleName === 'SuperAdmin');
    };
    
    // ============================================================
    // LOAD DATA
    // ============================================================
    $scope.loadPeriods = function() {
        $scope.loading = true;
        RegistrationPeriodService.getAll().then(function(response) {
            if (response.data.success) {
                $scope.periods = response.data.data;
            }
            $scope.loading = false;
        }).catch(function(error) {
            ToastService.error('Không thể tải danh sách đợt đăng ký');
            $scope.loading = false;
        });
    };
    
    $scope.loadActivePeriod = function() {
        RegistrationPeriodService.getActive().then(function(response) {
            if (response.data.success) {
                $scope.activePeriod = response.data.data;
            }
        }).catch(function(error) {
            // No active period is not an error
            $scope.activePeriod = null;
        });
    };
    
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll().then(function(response) {
            $scope.academicYears = response.data.data || response.data;
        });
    };
    
    // ============================================================
    // CREATE / UPDATE
    // ============================================================
    $scope.showCreateModal = function() {
        // Format dates as YYYY-MM-DD for date inputs
        var today = new Date();
        var year = today.getFullYear();
        var month = String(today.getMonth() + 1).padStart(2, '0');
        var day = String(today.getDate()).padStart(2, '0');
        var dateStr = year + '-' + month + '-' + day;
        
        $scope.currentPeriod = {
            periodName: '',
            academicYearId: '',
            semester: 1,
            startDate: dateStr,
            endDate: dateStr,
            status: 'UPCOMING',
            description: ''
        };
        $('#periodModal').modal('show');
    };
    
    // Format date for date input (YYYY-MM-DD format)
    function formatDateForInput(dateString) {
        if (!dateString) return null;
        try {
            var date = new Date(dateString);
            if (isNaN(date.getTime())) return null;
            // Format as YYYY-MM-DD for date input
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            return year + '-' + month + '-' + day;
        } catch (e) {
            return null;
        }
    }
    
    $scope.showEditModal = function(period) {
        $scope.currentPeriod = angular.copy(period);
        // Format dates for date inputs to avoid AngularJS datefmt error
        $scope.currentPeriod.startDate = formatDateForInput($scope.currentPeriod.startDate);
        $scope.currentPeriod.endDate = formatDateForInput($scope.currentPeriod.endDate);
        $('#periodModal').modal('show');
    };
    
    $scope.savePeriod = function() {
        if (!$scope.currentPeriod) return;
        
        // Validate dates
        if ($scope.currentPeriod.startDate >= $scope.currentPeriod.endDate) {
            ToastService.error('Ngày bắt đầu phải nhỏ hơn ngày kết thúc');
            return;
        }
        
        const isNew = !$scope.currentPeriod.periodId;
        const promise = isNew ? 
            RegistrationPeriodService.create($scope.currentPeriod) :
            RegistrationPeriodService.update($scope.currentPeriod.periodId, $scope.currentPeriod);
        
        promise.then(function(response) {
            if (response.data.success) {
                ToastService.success(isNew ? 'Tạo đợt đăng ký thành công' : 'Cập nhật đợt đăng ký thành công');
                $('#periodModal').modal('hide');
                $scope.loadPeriods();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Có lỗi xảy ra');
        });
    };
    
    // ============================================================
    // DELETE
    // ============================================================
    $scope.deletePeriod = function(periodId) {
        if (!confirm('Bạn có chắc chắn muốn xóa đợt đăng ký này?')) return;
        
        RegistrationPeriodService.delete(periodId).then(function(response) {
            if (response.data.success) {
                ToastService.success('Xóa đợt đăng ký thành công');
                $scope.loadPeriods();
                $scope.loadActivePeriod();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể xóa đợt đăng ký');
        });
    };
    
    // ============================================================
    // OPEN / CLOSE
    // ============================================================
    $scope.openPeriod = function(periodId) {
        if (!confirm('Mở đợt đăng ký này? Các đợt khác sẽ tự động đóng.')) return;
        
        RegistrationPeriodService.open(periodId).then(function(response) {
            if (response.data.success) {
                ToastService.success('Đã mở đợt đăng ký thành công');
                $scope.loadPeriods();
                $scope.loadActivePeriod();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể mở đợt đăng ký');
        });
    };
    
    $scope.closePeriod = function(periodId) {
        if (!confirm('Bạn có chắc chắn muốn đóng đợt đăng ký này?')) return;
        
        RegistrationPeriodService.close(periodId).then(function(response) {
            if (response.data.success) {
                ToastService.success('Đã đóng đợt đăng ký thành công');
                $scope.loadPeriods();
                $scope.loadActivePeriod();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể đóng đợt đăng ký');
        });
    };
    
    // ============================================================
    // UI HELPERS
    // ============================================================
    $scope.getStatusBadge = function(status) {
        switch(status) {
            case 'OPEN': return 'badge-success';
            case 'CLOSED': return 'badge-danger';
            case 'UPCOMING': return 'badge-warning';
            default: return 'badge-secondary';
        }
    };
    
    $scope.getSemesterName = function(semester) {
        return 'Học kỳ ' + semester;
    };
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.init = function() {
        $scope.loadPeriods();
        $scope.loadActivePeriod();
        $scope.loadAcademicYears();
    };
    
    $scope.init();
}]);

