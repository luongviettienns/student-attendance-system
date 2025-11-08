// Department Controller
app.controller('DepartmentController', ['$scope', '$location', '$routeParams', '$timeout', 'DepartmentService', 'FacultyService',
    function($scope, $location, $routeParams, $timeout, DepartmentService, FacultyService) {
    
    $scope.departments = [];
    $scope.department = {};
    $scope.faculties = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // ============================================================
    // 🔹 Load danh sách khoa (cho dropdown)
    // ============================================================
    $scope.loadFaculties = function() {
        FacultyService.getAll()
            .then(function(response) {
                $scope.faculties = response.data;
            })
            .catch(function(error) {
                // Error handled silently
            });
    };
    
    // ============================================================
    // 🔹 Load danh sách bộ môn
    // ============================================================
    $scope.loadDepartments = function() {
        $scope.loading = true;
        DepartmentService.getAll()
            .then(function(response) {
                $scope.departments = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách bộ môn';
                $scope.loading = false;
            });
    };
    
    // ============================================================
    // 🔹 Load bộ môn theo ID (cho chỉnh sửa)
    // ============================================================
    $scope.loadDepartment = function(id) {
        $scope.loading = true;
        DepartmentService.getById(id)
            .then(function(response) {
                $scope.department = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin bộ môn';
                $scope.loading = false;
            });
    };
    
    // ============================================================
    // 🔹 Lưu bộ môn (tạo mới hoặc cập nhật)
    // ============================================================
    $scope.saveDepartment = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = DepartmentService.update($scope.department.departmentId, $scope.department);
        } else {
            savePromise = DepartmentService.create($scope.department);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu bộ môn thành công';
                $scope.loading = false;
                $timeout(function() {
                    $location.path('/departments');
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu bộ môn';
                $scope.loading = false;
            });
    };
    
    // ============================================================
    // 🔹 Xóa bộ môn
    // ============================================================
    $scope.deleteDepartment = function(departmentId, departmentName) {
        if (!confirm('Bạn có chắc chắn muốn xóa bộ môn "' + departmentName + '"?\n\n' +
            'Lưu ý: Chỉ có thể xóa bộ môn không có môn học hoặc giảng viên liên kết.')) {
            return;
        }
        
        $scope.loading = true;
        DepartmentService.delete(departmentId)
            .then(function(response) {
                $scope.success = 'Xóa bộ môn thành công';
                $scope.loadDepartments();
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể xóa bộ môn';
                $scope.loading = false;
            });
    };
    
    // ============================================================
    // 🔹 Navigation
    // ============================================================
    $scope.goToCreate = function() {
        $location.path('/departments/create');
    };
    
    $scope.goToEdit = function(departmentId) {
        $location.path('/departments/edit/' + departmentId);
    };
    
    $scope.cancel = function() {
        $location.path('/departments');
    };
    
    // ============================================================
    // 🔹 Initialize
    // ============================================================
    if ($location.path() === '/departments') {
        $scope.loadDepartments();
    } else if ($location.path().indexOf('/departments/edit/') === 0 && $routeParams.id) {
        $scope.loadFaculties();
        $scope.loadDepartment($routeParams.id);
    } else if ($location.path() === '/departments/create') {
        $scope.loadFaculties();
        $scope.department.isActive = true; // Mặc định là active
    }
}]);

