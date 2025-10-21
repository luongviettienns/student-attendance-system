// Student Controller with Pagination, Search, Sort, Filter, Import/Export
app.controller('StudentController', ['$scope', '$location', '$routeParams', 'StudentService', 'FacultyService', 'MajorService', 'PaginationService', 'ExportService', 'ImportService', 'AuthService', 'AvatarService',
    function($scope, $location, $routeParams, StudentService, FacultyService, MajorService, PaginationService, ExportService, ImportService, AuthService, AvatarService) {
    
    $scope.students = [];
    $scope.displayedStudents = []; // For display after filtering/sorting
    $scope.faculties = [];
    $scope.majors = [];
    $scope.student = {};
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
        window.location.href = '#!/login';
    };
    
    // Pagination and filters
    $scope.pagination = PaginationService.init(10);
    $scope.filters = {
        facultyId: '',
        majorId: '',
        status: ''
    };
    
    // Import modal
    $scope.showImportModal = false;
    $scope.importData = {
        file: null,
        preview: [],
        errors: [],
        validCount: 0,
        errorCount: 0
    };
    
    // Load all students
    $scope.loadStudents = function() {
        $scope.loading = true;
        StudentService.getAll()
            .then(function(response) {
                $scope.students = response.data;
                $scope.applyFiltersAndSort();
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách sinh viên';
                $scope.loading = false;
            });
    };
    
    // Apply filters and sorting
    $scope.applyFiltersAndSort = function() {
        var filtered = $scope.students;
        
        // Apply search
        if ($scope.pagination.searchTerm) {
            var searchLower = $scope.pagination.searchTerm.toLowerCase();
            filtered = filtered.filter(function(student) {
                return (student.fullName && student.fullName.toLowerCase().includes(searchLower)) ||
                       (student.studentCode && student.studentCode.toLowerCase().includes(searchLower)) ||
                       (student.email && student.email.toLowerCase().includes(searchLower)) ||
                       (student.phone && student.phone.includes(searchLower));
            });
        }
        
        // Apply filters
        if ($scope.filters.facultyId) {
            filtered = filtered.filter(function(student) {
                return student.facultyId == $scope.filters.facultyId;
            });
        }
        
        if ($scope.filters.majorId) {
            filtered = filtered.filter(function(student) {
                return student.majorId == $scope.filters.majorId;
            });
        }
        
        if ($scope.filters.status !== '') {
            var isActive = $scope.filters.status === 'true';
            filtered = filtered.filter(function(student) {
                return student.isActive === isActive;
            });
        }
        
        // Apply sorting
        if ($scope.pagination.sortField) {
            filtered.sort(function(a, b) {
                var aVal = getNestedValue(a, $scope.pagination.sortField);
                var bVal = getNestedValue(b, $scope.pagination.sortField);
                
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
        $scope.displayedStudents = filtered.slice(start, end);
    };
    
    // Helper function to get nested object values
    function getNestedValue(obj, path) {
        return path.split('.').reduce(function(current, prop) {
            return current ? current[prop] : '';
        }, obj);
    }
    
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
    
    // Filter change handler
    $scope.handleFilterChange = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    // Reset filters
    $scope.resetFilters = function() {
        $scope.pagination.searchTerm = '';
        $scope.filters = {
            facultyId: '',
            majorId: '',
            status: ''
        };
        $scope.handleFilterChange();
    };
    
    // Export to Excel
    $scope.exportToExcel = function() {
        var columns = [
            { label: 'Mã SV', field: 'studentCode' },
            { label: 'Họ tên', field: 'fullName' },
            { label: 'Email', field: 'email' },
            { label: 'Số điện thoại', field: 'phone' },
            { label: 'Khoa', field: 'facultyName' },
            { label: 'Ngành', field: 'majorName' },
            { label: 'Trạng thái', field: 'isActive' }
        ];
        
        // Use current filtered data or all data
        var dataToExport = $scope.displayedStudents.length > 0 ? $scope.students : $scope.students;
        
        ExportService.exportToExcel(dataToExport, 'DanhSachSinhVien_' + new Date().toISOString().split('T')[0], columns);
    };
    
    // Export to CSV
    $scope.exportToCSV = function() {
        var columns = [
            { label: 'Mã SV', field: 'studentCode' },
            { label: 'Họ tên', field: 'fullName' },
            { label: 'Email', field: 'email' },
            { label: 'Số điện thoại', field: 'phone' },
            { label: 'Khoa', field: 'facultyName' },
            { label: 'Ngành', field: 'majorName' },
            { label: 'Trạng thái', field: 'isActive' }
        ];
        
        var dataToExport = $scope.displayedStudents.length > 0 ? $scope.students : $scope.students;
        
        ExportService.exportToCSV(dataToExport, 'DanhSachSinhVien_' + new Date().toISOString().split('T')[0], columns);
    };
    
    // Open import modal
    $scope.openImportModal = function() {
        $scope.showImportModal = true;
        $scope.importData = {
            file: null,
            preview: [],
            errors: [],
            validCount: 0,
            errorCount: 0
        };
    };
    
    // Close import modal
    $scope.closeImportModal = function() {
        $scope.showImportModal = false;
    };
    
    // Download import template
    $scope.downloadTemplate = function() {
        var columns = [
            { label: 'Mã SV', example: 'SV001' },
            { label: 'Họ tên', example: 'Nguyễn Văn A' },
            { label: 'Email', example: 'nva@example.com' },
            { label: 'Số điện thoại', example: '0123456789' },
            { label: 'Mã Khoa', example: '1' },
            { label: 'Mã Ngành', example: '1' }
        ];
        
        ImportService.downloadTemplate('MauNhapSinhVien', columns);
    };
    
    // Handle file selection
    $scope.onFileSelect = function(files) {
        if (files && files.length > 0) {
            $scope.importData.file = files[0];
            $scope.processImportFile();
        }
    };
    
    // Process import file
    $scope.processImportFile = function() {
        ImportService.readFile($scope.importData.file)
            .then(function(data) {
                // Validate data
                var schema = [
                    { name: 'Mã SV', label: 'Mã SV', required: true },
                    { name: 'Họ tên', label: 'Họ tên', required: true },
                    { name: 'Email', label: 'Email', required: true, type: 'email' },
                    { name: 'Số điện thoại', label: 'Số điện thoại', required: false },
                    { name: 'Mã Khoa', label: 'Mã Khoa', required: true, type: 'number' },
                    { name: 'Mã Ngành', label: 'Mã Ngành', required: true, type: 'number' }
                ];
                
                var result = ImportService.validate(data, schema);
                
                $scope.importData.preview = result.valid;
                $scope.importData.errors = result.invalid;
                $scope.importData.validCount = result.valid.length;
                $scope.importData.errorCount = result.invalid.length;
                
                $scope.$apply();
            })
            .catch(function(error) {
                $scope.error = error;
                $scope.$apply();
            });
    };
    
    // Confirm and import data
    $scope.confirmImport = function() {
        if ($scope.importData.validCount === 0) {
            $scope.error = 'Không có dữ liệu hợp lệ để import';
            return;
        }
        
        $scope.loading = true;
        
        // Transform data to match API format
        var studentsToImport = $scope.importData.preview.map(function(row) {
            return {
                studentCode: row['Mã SV'],
                fullName: row['Họ tên'],
                email: row['Email'],
                phone: row['Số điện thoại'] || '',
                facultyId: parseInt(row['Mã Khoa']),
                majorId: parseInt(row['Mã Ngành']),
                isActive: true
            };
        });
        
        // TODO: Call API to import students in batch
        // For now, we'll add them one by one (should be optimized with batch API)
        var importPromises = studentsToImport.map(function(student) {
            return StudentService.create(student);
        });
        
        Promise.all(importPromises)
            .then(function() {
                $scope.success = 'Import thành công ' + studentsToImport.length + ' sinh viên';
                $scope.loading = false;
                $scope.closeImportModal();
                $scope.loadStudents();
                $scope.$apply();
            })
            .catch(function(error) {
                $scope.error = 'Lỗi khi import: ' + (error.message || 'Vui lòng thử lại');
                $scope.loading = false;
                $scope.$apply();
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
    
    // Load majors for dropdown
    $scope.loadMajors = function() {
        MajorService.getAll()
            .then(function(response) {
                $scope.majors = response.data;
            })
            .catch(function(error) {
                console.error('Error loading majors:', error);
            });
    };
    
    // Load student by ID for editing
    $scope.loadStudent = function(id) {
        $scope.loading = true;
        StudentService.getById(id)
            .then(function(response) {
                $scope.student = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin sinh viên';
                $scope.loading = false;
            });
    };
    
    // Create or update student
    $scope.saveStudent = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = StudentService.update($scope.student.studentId, $scope.student);
        } else {
            savePromise = StudentService.create($scope.student);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu sinh viên thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/students');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu sinh viên';
                $scope.loading = false;
            });
    };
    
    // Delete student
    $scope.deleteStudent = function(studentId) {
        if (!confirm('Bạn có chắc chắn muốn xóa sinh viên này?')) {
            return;
        }
        
        StudentService.delete(studentId)
            .then(function(response) {
                $scope.success = 'Xóa sinh viên thành công';
                $scope.loadStudents();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa sinh viên';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/students/create');
    };
    
    $scope.goToEdit = function(studentId) {
        $location.path('/students/edit/' + studentId);
    };
    
    $scope.cancel = function() {
        $location.path('/students');
    };
    
    // Initialize based on route
    if ($location.path() === '/students') {
        $scope.loadStudents();
        $scope.loadFaculties();
        $scope.loadMajors();
    } else if ($routeParams.id) {
        $scope.loadStudent($routeParams.id);
        $scope.loadFaculties();
        $scope.loadMajors();
    } else {
        $scope.loadFaculties();
        $scope.loadMajors();
    }
}]);
