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
        AuthService.logout(); // Will auto-redirect to login
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
        // Khi đổi khoa → nạp lại danh sách ngành và reset ngành
        if (!$scope.filters.facultyId) {
            $scope.filters.majorId = '';
        }
        $scope.loadMajors();
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
            { label: 'Ngày sinh', field: 'dateOfBirth', type: 'date' },
            { label: 'Giới tính', field: 'gender' },
            { label: 'Khoa', field: 'facultyName' },
            { label: 'Ngành', field: 'majorName' },
            { label: 'Trạng thái', field: 'isActive' }
        ];
        
        // Use current filtered data or all data
        var dataToExport = $scope.students || [];
        
        // Export options with professional styling
        var exportOptions = {
            title: '📚 DANH SÁCH SINH VIÊN',
            info: [
                ['Đơn vị:', 'Trường Đại học ABC'],
                ['Thời gian xuất:', new Date().toLocaleDateString('vi-VN') + ' ' + new Date().toLocaleTimeString('vi-VN')],
                ['Người xuất:', $scope.currentUser ? $scope.currentUser.fullName : 'Admin']
            ],
            sheetName: 'Sinh viên',
            showSummary: true
        };
        
        ExportService.exportToExcel(dataToExport, 'DanhSachSinhVien', columns, exportOptions);
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
            { 
                label: 'Mã SV', 
                example: 'SV2024003',
                required: true,
                note: 'Mã sinh viên duy nhất, không trùng lặp. Định dạng: SV + năm + số (VD: SV2024003, SV2024004)'
            },
            { 
                label: 'Họ tên', 
                example: 'Nguyễn Văn Cường',
                required: true,
                note: 'Họ và tên đầy đủ của sinh viên'
            },
            { 
                label: 'Email', 
                example: 'nguyenvancuong@student.edu.vn',
                required: true,
                note: 'Email sinh viên, phải đúng định dạng có chứa @. Không trùng lặp'
            },
            { 
                label: 'Số điện thoại', 
                example: '0912345678',
                required: false,
                note: 'Số điện thoại di động, 10-11 chữ số, bắt đầu bằng 0'
            },
            { 
                label: 'Ngày sinh', 
                example: '2003-03-15',
                required: false,
                note: 'Định dạng: YYYY-MM-DD (VD: 2003-03-15, 2003-07-22)'
            },
            { 
                label: 'Giới tính', 
                example: 'Nam',
                required: false,
                note: 'Giá trị: Nam hoặc Nữ (phân biệt chữ hoa/thường)'
            },
            { 
                label: 'Địa chỉ', 
                example: 'Số 10, Đường Lê Lợi, Quận 1, TP.HCM',
                required: false,
                note: 'Địa chỉ thường trú hoặc tạm trú (đầy đủ)'
            },
            { 
                label: 'Mã Ngành', 
                example: 'MAJ001',
                required: true,
                note: 'CHỈ dùng: MAJ001 (Công nghệ Phần mềm) hoặc MAJ002 (Khoa học Dữ liệu). Xem sheet "Mã tham khảo"'
            },
            { 
                label: 'Niên khóa', 
                example: 'AY2024',
                required: false,
                note: 'CHỈ dùng: AY2024 (KHÔNG phải AY2024-2025!). Có thể để trống. Xem sheet "Mã tham khảo"'
            }
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
                    { 
                        name: 'Mã SV (*)', 
                        label: 'Mã SV', 
                        required: true,
                        validate: function(value) {
                            if (!/^SV\d+$/i.test(value)) {
                                return 'Mã SV phải có định dạng SV + số (VD: SV001)';
                            }
                        }
                    },
                    { 
                        name: 'Họ tên (*)', 
                        label: 'Họ tên', 
                        required: true 
                    },
                    { 
                        name: 'Email (*)', 
                        label: 'Email', 
                        required: true, 
                        type: 'email' 
                    },
                    { 
                        name: 'Số điện thoại', 
                        label: 'Số điện thoại', 
                        required: false,
                        validate: function(value) {
                            if (value && !/^\d{10,11}$/.test(value.toString().replace(/\s/g, ''))) {
                                return 'Số điện thoại phải có 10-11 chữ số';
                            }
                        }
                    },
                    { 
                        name: 'Ngày sinh', 
                        label: 'Ngày sinh', 
                        required: false,
                        type: 'date'
                    },
                    { 
                        name: 'Giới tính', 
                        label: 'Giới tính', 
                        required: false,
                        validate: function(value) {
                            if (value && !['Nam', 'Nữ', 'nam', 'nữ'].includes(value)) {
                                return 'Giới tính chỉ được là "Nam" hoặc "Nữ"';
                            }
                        }
                    },
                    { 
                        name: 'Địa chỉ', 
                        label: 'Địa chỉ', 
                        required: false 
                    },
                    { 
                        name: 'Mã Ngành (*)', 
                        label: 'Mã Ngành', 
                        required: true 
                    },
                    { 
                        name: 'Niên khóa', 
                        label: 'Niên khóa', 
                        required: false
                    }
                ];
                
                var result = ImportService.validate(data, schema);
                
                $scope.importData.preview = result.valid;
                $scope.importData.errors = result.invalid;
                $scope.importData.validCount = result.valid.length;
                $scope.importData.errorCount = result.invalid.length;
            })
            .catch(function(error) {
                $scope.error = error;
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
            // Parse date if exists
            var dob = null;
            if (row['Ngày sinh']) {
                dob = new Date(row['Ngày sinh']).toISOString();
            }
            
            return {
                studentCode: row['Mã SV'],
                fullName: row['Họ tên'],
                email: row['Email'],
                phone: row['Số điện thoại'] || null,
                dateOfBirth: dob,
                gender: row['Giới tính'] || null,
                address: row['Địa chỉ'] || null,
                majorId: row['Mã Ngành'] || row['Mã Ngành (*)'],
                academicYearId: row['Niên khóa'] || null
            };
        });
        
        // ✅ Use BATCH IMPORT API (1 request instead of N requests)
        StudentService.importBatch(studentsToImport)
            .then(function(response) {
                var result = response.data.data;
                
                if (result.errorCount > 0) {
                    // Show partial success with errors
                    var errorMessages = result.errors.map(function(err) {
                        return 'Dòng ' + err.rowNumber + ' (' + err.studentCode + '): ' + err.errorMessage;
                    }).join('\n');
                    
                    $scope.error = 'Import thành công ' + result.successCount + '/' + studentsToImport.length + ' sinh viên.\n\n' +
                                   'Có ' + result.errorCount + ' lỗi:\n' + errorMessages;
                } else {
                    // Full success
                    $scope.success = 'Import thành công ' + result.successCount + ' sinh viên! 🎉';
                }
                
                $scope.loading = false;
                $scope.closeImportModal();
                $scope.loadStudents();
            })
            .catch(function(error) {
                $scope.error = 'Lỗi khi import: ' + (error.data?.message || error.message || 'Vui lòng thử lại');
                $scope.loading = false;
            });
    };
    
    // Load faculties for dropdown
    $scope.loadFaculties = function() {
        FacultyService.getAll()
            .then(function(response) {
                var list = response.data?.data || response.data || [];
                $scope.faculties = list;
            })
            .catch(function(error) {
                console.error('Error loading faculties:', error);
            });
    };
    
    // Load majors for dropdown
    $scope.loadMajors = function() {
        if ($scope.filters.facultyId) {
            MajorService.getByFaculty($scope.filters.facultyId)
                .then(function(response) {
                    var list = response.data?.data || response.data || [];
                    $scope.majors = list;
                })
                .catch(function(error) {
                    console.error('Error loading majors by faculty:', error);
                });
        } else {
            $scope.majors = [];
        }
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
