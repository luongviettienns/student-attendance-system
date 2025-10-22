// Academic Year Controller
app.controller('AcademicYearController', ['$scope', '$location', '$routeParams', 'AcademicYearService', 'AuthService', 'AvatarService',
    function($scope, $location, $routeParams, AcademicYearService, AuthService, AvatarService) {
    
    $scope.academicYears = [];
    $scope.academicYear = {};
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
        AuthService.logout(); // Will auto-redirect to login
    };
    
    // Load all academic years
    $scope.loadAcademicYears = function() {
        $scope.loading = true;
        AcademicYearService.getAll()
            .then(function(response) {
                $scope.academicYears = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách niên khóa';
                $scope.loading = false;
            });
    };
    
    // Load academic year by ID for editing
    $scope.loadAcademicYear = function(id) {
        $scope.loading = true;
        AcademicYearService.getById(id)
            .then(function(response) {
                $scope.academicYear = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin niên khóa';
                $scope.loading = false;
            });
    };
    
    // Create or update academic year
    $scope.saveAcademicYear = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = AcademicYearService.update($scope.academicYear.academicYearId, $scope.academicYear);
        } else {
            savePromise = AcademicYearService.create($scope.academicYear);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu niên khóa thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/academic-years');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu niên khóa';
                $scope.loading = false;
            });
    };
    
    // Delete academic year
    $scope.deleteAcademicYear = function(academicYearId) {
        if (!confirm('Bạn có chắc chắn muốn xóa niên khóa này?')) {
            return;
        }
        
        AcademicYearService.delete(academicYearId)
            .then(function(response) {
                $scope.success = 'Xóa niên khóa thành công';
                $scope.loadAcademicYears();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa niên khóa';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/academic-years/create');
    };
    
    $scope.goToEdit = function(academicYearId) {
        $location.path('/academic-years/edit/' + academicYearId);
    };
    
    $scope.cancel = function() {
        $location.path('/academic-years');
    };
    
    // Initialize based on route
    if ($location.path() === '/academic-years') {
        $scope.loadAcademicYears();
    } else if ($routeParams.id) {
        $scope.loadAcademicYear($routeParams.id);
    }
}]);

