// Faculty Controller with Pagination, Search, Sort, Export
app.controller('FacultyController', ['$scope', '$location', '$routeParams', 'FacultyService', 'PaginationService', 'ExportService',
    function($scope, $location, $routeParams, FacultyService, PaginationService, ExportService) {
    
    $scope.faculties = [];
    $scope.displayedFaculties = [];
    $scope.faculty = {};
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // Pagination
    $scope.pagination = PaginationService.init(10);
    
    // Load all faculties
    $scope.loadFaculties = function() {
        $scope.loading = true;
        FacultyService.getAll()
            .then(function(response) {
                $scope.faculties = response.data;
                $scope.applyFiltersAndSort();
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách khoa';
                $scope.loading = false;
            });
    };
    
    // Apply filters and sorting
    $scope.applyFiltersAndSort = function() {
        var filtered = $scope.faculties;
        
        // Apply search
        if ($scope.pagination.searchTerm) {
            var searchLower = $scope.pagination.searchTerm.toLowerCase();
            filtered = filtered.filter(function(faculty) {
                return (faculty.facultyName && faculty.facultyName.toLowerCase().includes(searchLower)) ||
                       (faculty.facultyCode && faculty.facultyCode.toLowerCase().includes(searchLower)) ||
                       (faculty.description && faculty.description.toLowerCase().includes(searchLower));
            });
        }
        
        // Apply sorting
        if ($scope.pagination.sortField) {
            filtered.sort(function(a, b) {
                var aVal = a[$scope.pagination.sortField] || '';
                var bVal = b[$scope.pagination.sortField] || '';
                
                if (aVal < bVal) return $scope.pagination.sortDirection === 'asc' ? -1 : 1;
                if (aVal > bVal) return $scope.pagination.sortDirection === 'asc' ? 1 : -1;
                return 0;
            });
        }
        
        // Update pagination
        $scope.pagination.totalItems = filtered.length;
        $scope.pagination = PaginationService.calculate($scope.pagination);
        
        // Apply pagination
        var start = ($scope.pagination.currentPage - 1) * $scope.pagination.pageSize;
        var end = start + parseInt($scope.pagination.pageSize);
        $scope.displayedFaculties = filtered.slice(start, end);
    };
    
    // Search handler
    $scope.handleSearch = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    // Sort handler
    $scope.handleSort = function() {
        $scope.applyFiltersAndSort();
    };
    
    // Page change handler
    $scope.handlePageChange = function() {
        $scope.applyFiltersAndSort();
    };
    
    // Export to Excel
    $scope.exportToExcel = function() {
        var columns = [
            { label: 'Mã khoa', field: 'facultyCode' },
            { label: 'Tên khoa', field: 'facultyName' },
            { label: 'Mô tả', field: 'description' }
        ];
        
        ExportService.exportToExcel($scope.faculties, 'DanhSachKhoa_' + new Date().toISOString().split('T')[0], columns);
    };
    
    // Export to CSV
    $scope.exportToCSV = function() {
        var columns = [
            { label: 'Mã khoa', field: 'facultyCode' },
            { label: 'Tên khoa', field: 'facultyName' },
            { label: 'Mô tả', field: 'description' }
        ];
        
        ExportService.exportToCSV($scope.faculties, 'DanhSachKhoa_' + new Date().toISOString().split('T')[0], columns);
    };
    
    // Load faculty by ID for editing
    $scope.loadFaculty = function(id) {
        $scope.loading = true;
        FacultyService.getById(id)
            .then(function(response) {
                $scope.faculty = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin khoa';
                $scope.loading = false;
            });
    };
    
    // Create or update faculty
    $scope.saveFaculty = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = FacultyService.update($scope.faculty.facultyId, $scope.faculty);
        } else {
            savePromise = FacultyService.create($scope.faculty);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu khoa thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/faculties');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu khoa';
                $scope.loading = false;
            });
    };
    
    // Delete faculty
    $scope.deleteFaculty = function(facultyId) {
        if (!confirm('Bạn có chắc chắn muốn xóa khoa này?')) {
            return;
        }
        
        FacultyService.delete(facultyId)
            .then(function(response) {
                $scope.success = 'Xóa khoa thành công';
                $scope.loadFaculties();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa khoa';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/faculties/create');
    };
    
    $scope.goToEdit = function(facultyId) {
        $location.path('/faculties/edit/' + facultyId);
    };
    
    $scope.cancel = function() {
        $location.path('/faculties');
    };
    
    // Initialize based on route
    if ($location.path() === '/faculties') {
        $scope.loadFaculties();
    } else if ($routeParams.id) {
        $scope.loadFaculty($routeParams.id);
    }
}]);
