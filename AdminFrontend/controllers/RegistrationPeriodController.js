// ============================================================
// REGISTRATION PERIOD CONTROLLER
// Quản lý đợt đăng ký học phần
// ============================================================
app.controller('RegistrationPeriodController', [
    '$scope', '$timeout', 'RegistrationPeriodService', 'AcademicYearService', 'ToastService', 'AuthService',
    function($scope, $timeout, RegistrationPeriodService, AcademicYearService, ToastService, AuthService) {
    
    // ============================================================
    // VARIABLES INITIALIZATION
    // ============================================================
    $scope.periods = [];
    $scope.activePeriod = null;
    $scope.currentPeriod = null;
    $scope.academicYears = [];
    $scope.loading = false;
    
    // Period Classes Management
    $scope.periodClasses = [];
    $scope.availableClasses = [];
    $scope.selectedPeriod = null;
    
    // ============================================================
    // AUTHORIZATION
    // ============================================================
    $scope.isAdmin = function() {
        var user = AuthService.getCurrentUser();
        if (!user) return false;
        var role = user.roleName || user.Role || user.role || '';
        return role === 'Admin' || role === 'SuperAdmin' || role === 'Quản trị viên';
    };
    
    // ============================================================
    // MODAL MANAGEMENT
    // ============================================================
    var openModal = function() {
        try {
            if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                window.ModalUtils.open('periodModal');
            } else {
                // Fallback: use jQuery
                var $modal = $('#periodModal');
                var $overlay = $('#modal-overlay');
                if ($modal.length && $overlay.length) {
                    $modal.addClass('active');
                    $overlay.addClass('active');
                    $('body').css('overflow', 'hidden');
                }
            }
        } catch (error) {
            console.error('Error opening modal:', error);
        }
    };
    
    var closeModal = function() {
        try {
            if (window.ModalUtils && typeof window.ModalUtils.close === 'function') {
                window.ModalUtils.close('periodModal');
            } else if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
                window.ModalUtils.closeAll();
            } else {
                // Fallback: use jQuery
                var $modal = $('#periodModal');
                var $overlay = $('#modal-overlay');
                if ($modal.length && $overlay.length) {
                    $modal.removeClass('active');
                    $overlay.removeClass('active');
                    $('body').css('overflow', '');
                }
            }
        } catch (error) {
            console.error('Error closing modal:', error);
        }
    };
    
    $scope.closeModal = closeModal;
    
    // ============================================================
    // LOAD DATA
    // ============================================================
    $scope.loadPeriods = function() {
        $scope.loading = true;
        RegistrationPeriodService.getAll()
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.periods = response.data.data || [];
                } else {
                    $scope.periods = [];
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading periods:', error);
                ToastService.error('Không thể tải danh sách đợt đăng ký');
                $scope.periods = [];
                $scope.loading = false;
            });
    };
    
    $scope.loadActivePeriod = function() {
        RegistrationPeriodService.getActive()
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.activePeriod = response.data.data;
                } else {
                    $scope.activePeriod = null;
                }
            })
            .catch(function(error) {
                // No active period is not an error
                $scope.activePeriod = null;
            });
    };
    
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll()
            .then(function(response) {
                if (response.data) {
                    $scope.academicYears = response.data.data || response.data || [];
                } else {
                    $scope.academicYears = [];
                }
            })
            .catch(function(error) {
                console.error('Error loading academic years:', error);
                $scope.academicYears = [];
            });
    };
    
    // ============================================================
    // CREATE / UPDATE PERIOD
    // ============================================================
    $scope.showCreateModal = function() {
        try {
            // Format today's date as YYYY-MM-DD for date inputs
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
            
            // Use $timeout to ensure DOM is ready
            $timeout(function() {
                openModal();
            }, 50);
        } catch (error) {
            console.error('Error in showCreateModal:', error);
            ToastService.error('Lỗi khi mở form: ' + error.message);
        }
    };
    
    // Format date for date input (YYYY-MM-DD format)
    function formatDateForInput(dateString) {
        if (!dateString) return null;
        try {
            var date = new Date(dateString);
            if (isNaN(date.getTime())) return null;
            var year = date.getFullYear();
            var month = String(date.getMonth() + 1).padStart(2, '0');
            var day = String(date.getDate()).padStart(2, '0');
            return year + '-' + month + '-' + day;
        } catch (e) {
            console.error('Error formatting date:', e);
            return null;
        }
    }
    
    $scope.showEditModal = function(period) {
        if (!period) return;
        
        $scope.currentPeriod = angular.copy(period);
        // Format dates for date inputs
        $scope.currentPeriod.startDate = formatDateForInput($scope.currentPeriod.startDate);
        $scope.currentPeriod.endDate = formatDateForInput($scope.currentPeriod.endDate);
        
        // Use $timeout to ensure DOM is ready
        $timeout(function() {
            openModal();
        }, 50);
    };
    
    $scope.savePeriod = function() {
        if (!$scope.currentPeriod) {
            ToastService.error('Dữ liệu không hợp lệ');
            return;
        }
        
        // Validate required fields
        if (!$scope.currentPeriod.periodName || !$scope.currentPeriod.periodName.trim()) {
            ToastService.error('Vui lòng nhập tên đợt đăng ký');
            return;
        }
        
        if (!$scope.currentPeriod.academicYearId) {
            ToastService.error('Vui lòng chọn năm học');
            return;
        }
        
        // Validate dates
        if (!$scope.currentPeriod.startDate || !$scope.currentPeriod.endDate) {
            ToastService.error('Vui lòng nhập đầy đủ ngày bắt đầu và ngày kết thúc');
            return;
        }
        
        if ($scope.currentPeriod.startDate >= $scope.currentPeriod.endDate) {
            ToastService.error('Ngày bắt đầu phải nhỏ hơn ngày kết thúc');
            return;
        }
        
        var isNew = !$scope.currentPeriod.periodId;
        var promise = isNew ? 
            RegistrationPeriodService.create($scope.currentPeriod) :
            RegistrationPeriodService.update($scope.currentPeriod.periodId, $scope.currentPeriod);
        
        promise
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success(isNew ? 'Tạo đợt đăng ký thành công' : 'Cập nhật đợt đăng ký thành công');
                    closeModal();
                    $scope.currentPeriod = null;
                    $scope.loadPeriods();
                    $scope.loadActivePeriod();
                } else {
                    ToastService.error(response.data?.message || 'Có lỗi xảy ra');
                }
            })
            .catch(function(error) {
                console.error('Error saving period:', error);
                var errorMsg = error.data?.message || error.message || 'Có lỗi xảy ra';
                ToastService.error(errorMsg);
            });
    };
    
    // ============================================================
    // DELETE PERIOD
    // ============================================================
    $scope.deletePeriod = function(periodId) {
        if (!periodId) return;
        
        if (!confirm('Bạn có chắc chắn muốn xóa đợt đăng ký này?')) {
            return;
        }
        
        RegistrationPeriodService.delete(periodId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success('Xóa đợt đăng ký thành công');
                    $scope.loadPeriods();
                    $scope.loadActivePeriod();
                } else {
                    ToastService.error(response.data?.message || 'Không thể xóa đợt đăng ký');
                }
            })
            .catch(function(error) {
                console.error('Error deleting period:', error);
                var errorMsg = error.data?.message || error.message || 'Không thể xóa đợt đăng ký';
                ToastService.error(errorMsg);
            });
    };
    
    // ============================================================
    // OPEN / CLOSE PERIOD
    // ============================================================
    $scope.openPeriod = function(periodId) {
        if (!periodId) return;
        
        if (!confirm('Mở đợt đăng ký này? Các đợt khác sẽ tự động đóng.')) {
            return;
        }
        
        RegistrationPeriodService.open(periodId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success('Đã mở đợt đăng ký thành công');
                    $scope.loadPeriods();
                    $scope.loadActivePeriod();
                } else {
                    ToastService.error(response.data?.message || 'Không thể mở đợt đăng ký');
                }
            })
            .catch(function(error) {
                console.error('Error opening period:', error);
                var errorMsg = error.data?.message || error.message || 'Không thể mở đợt đăng ký';
                ToastService.error(errorMsg);
            });
    };
    
    $scope.closePeriod = function(periodId) {
        if (!periodId) return;
        
        if (!confirm('Bạn có chắc chắn muốn đóng đợt đăng ký này?')) {
            return;
        }
        
        RegistrationPeriodService.close(periodId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success('Đã đóng đợt đăng ký thành công');
                    $scope.loadPeriods();
                    $scope.loadActivePeriod();
                } else {
                    ToastService.error(response.data?.message || 'Không thể đóng đợt đăng ký');
                }
            })
            .catch(function(error) {
                console.error('Error closing period:', error);
                var errorMsg = error.data?.message || error.message || 'Không thể đóng đợt đăng ký';
                ToastService.error(errorMsg);
            });
    };
    
    // ============================================================
    // UI HELPERS
    // ============================================================
    $scope.getStatusBadge = function(status) {
        if (!status) return 'badge-secondary';
        switch(status.toUpperCase()) {
            case 'OPEN': return 'badge-success';
            case 'CLOSED': return 'badge-danger';
            case 'UPCOMING': return 'badge-warning';
            default: return 'badge-secondary';
        }
    };
    
    $scope.getSemesterName = function(semester) {
        if (!semester) return 'Không xác định';
        if (semester === 1) return 'Học kỳ 1';
        if (semester === 2) return 'Học kỳ 2';
        if (semester === 3) return 'Học kỳ 3 (Hè)';
        return 'Học kỳ ' + semester;
    };
    
    // ============================================================
    // PERIOD CLASSES MANAGEMENT
    // ============================================================
    $scope.loadPeriodClasses = function(periodId) {
        if (!periodId) return;
        
        $scope.selectedPeriod = periodId;
        $scope.periodClasses = [];
        $scope.availableClasses = [];
        
        // Load classes in period
        RegistrationPeriodService.getClassesByPeriod(periodId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.periodClasses = response.data.data || [];
                } else {
                    $scope.periodClasses = [];
                }
            })
            .catch(function(error) {
                console.error('Error loading period classes:', error);
                $scope.periodClasses = [];
            });
        
        // Load available classes
        RegistrationPeriodService.getAvailableClassesForPeriod(periodId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.availableClasses = response.data.data || [];
                } else {
                    $scope.availableClasses = [];
                }
            })
            .catch(function(error) {
                console.error('Error loading available classes:', error);
                $scope.availableClasses = [];
            });
    };
    
    $scope.addClassToPeriod = function(classId) {
        if (!$scope.selectedPeriod || !classId) return;
        
        RegistrationPeriodService.addClassToPeriod($scope.selectedPeriod, classId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success('Thêm lớp vào đợt đăng ký thành công');
                    $scope.loadPeriodClasses($scope.selectedPeriod);
                } else {
                    ToastService.error(response.data?.message || 'Không thể thêm lớp');
                }
            })
            .catch(function(error) {
                console.error('Error adding class to period:', error);
                var errorMsg = error.data?.message || error.message || 'Không thể thêm lớp';
                ToastService.error(errorMsg);
            });
    };
    
    $scope.removeClassFromPeriod = function(periodClassId) {
        if (!periodClassId) return;
        
        if (!confirm('Bạn có chắc muốn xóa lớp này khỏi đợt đăng ký?')) {
            return;
        }
        
        RegistrationPeriodService.removeClassFromPeriod(periodClassId)
            .then(function(response) {
                if (response.data && response.data.success) {
                    ToastService.success('Xóa lớp khỏi đợt đăng ký thành công');
                    if ($scope.selectedPeriod) {
                        $scope.loadPeriodClasses($scope.selectedPeriod);
                    }
                } else {
                    ToastService.error(response.data?.message || 'Không thể xóa lớp');
                }
            })
            .catch(function(error) {
                console.error('Error removing class from period:', error);
                var errorMsg = error.data?.message || error.message || 'Không thể xóa lớp';
                ToastService.error(errorMsg);
            });
    };
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.init = function() {
        // Ensure modal is closed on page load
        $timeout(function() {
            closeModal();
        }, 200);
        
        // Load data
        $scope.loadPeriods();
        $scope.loadActivePeriod();
        $scope.loadAcademicYears();
    };
    
    // Initialize when controller loads
    $scope.init();
}]);
