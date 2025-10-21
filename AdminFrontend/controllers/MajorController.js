// Major Controller
app.controller('MajorController', ['$scope', '$location', '$routeParams', 'MajorService', 'FacultyService',
    function($scope, $location, $routeParams, MajorService, FacultyService) {
    
    $scope.majors = [];
    $scope.faculties = [];
    $scope.major = {};
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // Load all majors
    $scope.loadMajors = function() {
        $scope.loading = true;
        MajorService.getAll()
            .then(function(response) {
                $scope.majors = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách ngành';
                $scope.loading = false;
            });
    };
    
    // Load faculties for dropdown
    $scope.loadFaculties = function() {
        FacultyService.getAll()
            .then(function(response) {
                $scope.faculties = response.data;
            })
            .catch(function(error) {
                console.error('Error loading faculties:', error);
            });
    };
    
    // Load major by ID for editing
    $scope.loadMajor = function(id) {
        $scope.loading = true;
        MajorService.getById(id)
            .then(function(response) {
                $scope.major = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin ngành';
                $scope.loading = false;
            });
    };
    
    // Create or update major
    $scope.saveMajor = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = MajorService.update($scope.major.majorId, $scope.major);
        } else {
            savePromise = MajorService.create($scope.major);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu ngành thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/majors');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu ngành';
                $scope.loading = false;
            });
    };
    
    // Delete major
    $scope.deleteMajor = function(majorId) {
        if (!confirm('Bạn có chắc chắn muốn xóa ngành này?')) {
            return;
        }
        
        MajorService.delete(majorId)
            .then(function(response) {
                $scope.success = 'Xóa ngành thành công';
                $scope.loadMajors();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa ngành';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/majors/create');
    };
    
    $scope.goToEdit = function(majorId) {
        $location.path('/majors/edit/' + majorId);
    };
    
    $scope.cancel = function() {
        $location.path('/majors');
    };
    
    // Initialize based on route
    if ($location.path() === '/majors') {
        $scope.loadMajors();
    } else if ($routeParams.id) {
        $scope.loadMajor($routeParams.id);
        $scope.loadFaculties();
    } else {
        $scope.loadFaculties();
    }
}]);

