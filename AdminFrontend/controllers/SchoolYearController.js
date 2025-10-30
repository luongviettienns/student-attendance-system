// School Year Controller
app.controller('SchoolYearController', ['$scope', '$location', '$routeParams', 'SchoolYearService', 'AcademicYearService', 'AuthService', 'AvatarService', 'ToastService',
    function($scope, $location, $routeParams, SchoolYearService, AcademicYearService, AuthService, AvatarService, ToastService) {
    
    $scope.schoolYears = [];
    $scope.currentSchoolYear = null;
    $scope.currentSemesterInfo = null;
    $scope.schoolYear = {};
    $scope.academicYears = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Get current user for header
    $scope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    // Logout function
    $scope.logout = function() {
        AuthService.logout();
    };
    
    // Load all school years
    $scope.loadSchoolYears = function() {
        $scope.loading = true;
        SchoolYearService.getAll()
            .then(function(response) {
                $scope.schoolYears = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách năm học';
                $scope.loading = false;
                console.error('Error loading school years:', error);
            });
    };
    
    // Load current school year
    $scope.loadCurrentSchoolYear = function() {
        SchoolYearService.getCurrent()
            .then(function(response) {
                $scope.currentSchoolYear = response.data;
            })
            .catch(function(error) {
                console.error('Error loading current school year:', error);
            });
    };
    
    // Load current semester info
    $scope.loadCurrentSemesterInfo = function() {
        SchoolYearService.getCurrentSemesterInfo()
            .then(function(response) {
                $scope.currentSemesterInfo = response.data;
            })
            .catch(function(error) {
                console.error('Error loading current semester info:', error);
            });
    };
    
    // Load academic years for dropdown
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll()
            .then(function(response) {
                $scope.academicYears = response.data;
            })
            .catch(function(error) {
                console.error('Error loading academic years:', error);
            });
    };
    
    // Load school year by ID for editing
    $scope.loadSchoolYear = function(id) {
        $scope.loading = true;
        SchoolYearService.getById(id)
            .then(function(response) {
                $scope.schoolYear = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin năm học';
                $scope.loading = false;
                console.error('Error loading school year:', error);
            });
    };
    
    // Activate school year
    $scope.activateSchoolYear = function(schoolYearId, semester) {
        if (!confirm('Bạn có chắc chắn muốn kích hoạt năm học này?')) {
            return;
        }
        
        var semesterToActivate = semester || 1;
        $scope.loading = true;
        
        SchoolYearService.activate(schoolYearId, semesterToActivate)
            .then(function(response) {
                ToastService.success('Đã kích hoạt năm học thành công!');
                $scope.loadSchoolYears();
                $scope.loadCurrentSchoolYear();
                $scope.loadCurrentSemesterInfo();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể kích hoạt năm học');
                console.error('Error activating school year:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Deactivate school year
    $scope.deactivateSchoolYear = function(schoolYearId) {
        if (!confirm('Bạn có chắc chắn muốn hủy kích hoạt năm học này?')) {
            return;
        }
        
        $scope.loading = true;
        SchoolYearService.deactivate(schoolYearId)
            .then(function(response) {
                ToastService.success('Đã hủy kích hoạt năm học!');
                $scope.loadSchoolYears();
                $scope.loadCurrentSchoolYear();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể hủy kích hoạt năm học');
                console.error('Error deactivating school year:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Auto-create school years for cohort
    $scope.autoCreateForCohort = function() {
        var startYear = prompt('Nhập năm bắt đầu của khóa (VD: 2025 cho K25):');
        if (!startYear || isNaN(startYear)) {
            ToastService.warning('Năm không hợp lệ!');
            return;
        }
        
        $scope.loading = true;
        SchoolYearService.autoCreateForCohort(parseInt(startYear))
            .then(function(response) {
                ToastService.success('Đã tự động tạo năm học cho khóa K' + startYear.substring(2) + '!');
                $scope.loadSchoolYears();
                $scope.loadAcademicYears();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể tự động tạo năm học');
                console.error('Error auto-creating school years:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Transition to next semester
    $scope.transitionToNextSemester = function() {
        if (!confirm('Bạn có chắc chắn muốn chuyển sang học kỳ tiếp theo? Hệ thống sẽ tự động xác định học kỳ dựa trên ngày hiện tại.')) {
            return;
        }
        
        $scope.loading = true;
        SchoolYearService.transitionToNextSemester()
            .then(function(response) {
                ToastService.success('Đã chuyển sang học kỳ mới thành công!');
                $scope.loadSchoolYears();
                $scope.loadCurrentSchoolYear();
                $scope.loadCurrentSemesterInfo();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể chuyển học kỳ');
                console.error('Error transitioning semester:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Create or update school year
    $scope.saveSchoolYear = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = SchoolYearService.update($scope.schoolYear.schoolYearId, $scope.schoolYear);
        } else {
            savePromise = SchoolYearService.create($scope.schoolYear);
        }
        
        savePromise
            .then(function(response) {
                ToastService.success('Lưu năm học thành công!');
                setTimeout(function() {
                    $location.path('/school-years');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu năm học';
                ToastService.error($scope.error);
                console.error('Error saving school year:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Delete school year
    $scope.deleteSchoolYear = function(schoolYearId) {
        if (!confirm('Bạn có chắc chắn muốn xóa năm học này?')) {
            return;
        }
        
        $scope.loading = true;
        SchoolYearService.delete(schoolYearId)
            .then(function(response) {
                ToastService.success('Xóa năm học thành công!');
                $scope.loadSchoolYears();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa năm học');
                console.error('Error deleting school year:', error);
            })
            .finally(function() {
                $scope.loading = false;
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/school-years/create');
    };
    
    $scope.goToEdit = function(schoolYearId) {
        $location.path('/school-years/edit/' + schoolYearId);
    };
    
    $scope.cancel = function() {
        $location.path('/school-years');
    };
    
    // Utility functions
    $scope.getSemesterName = function(semester) {
        if (semester === 1) return 'Học kỳ 1 (Sep-Jan)';
        if (semester === 2) return 'Học kỳ 2 (Feb-Jun)';
        return 'N/A';
    };
    
    $scope.formatDateRange = function(startDate, endDate) {
        if (!startDate || !endDate) return '';
        var start = new Date(startDate);
        var end = new Date(endDate);
        return start.toLocaleDateString('vi-VN') + ' - ' + end.toLocaleDateString('vi-VN');
    };
    
    // Initialize based on route
    if ($location.path() === '/school-years') {
        $scope.loadSchoolYears();
        $scope.loadCurrentSchoolYear();
        $scope.loadCurrentSemesterInfo();
    } else if ($routeParams.id) {
        $scope.loadSchoolYear($routeParams.id);
        $scope.loadAcademicYears();
    } else if ($location.path() === '/school-years/create') {
        $scope.loadAcademicYears();
    }
}]);

