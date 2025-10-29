// ============================================================
// ORGANIZATION CONTROLLER - Quản lý Khoa, Bộ môn, Ngành (Gom chung)
// ============================================================
app.controller('OrganizationController', ['$scope', '$http', 'API_CONFIG', 'AuthService', 'AvatarService', 'ToastService', 'FacultyService', 'PaginationService', function($scope, $http, API_CONFIG, AuthService, AvatarService, ToastService, FacultyService, PaginationService) {
    
    // =========================
    // INITIALIZATION
    // =========================
    $scope.activeTab = 'faculties';
    $scope.faculties = [];
    $scope.departments = [];
    $scope.majors = [];
    $scope.subjects = [];
    
    // ✅ Initialize Pagination
    $scope.facultyPagination = PaginationService.init(10);
    
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
    
    // Tab switching function
    $scope.switchTab = function(tabName) {
        $scope.activeTab = tabName;
    };
    
    $scope.facultyForm = {};
    $scope.departmentForm = {};
    $scope.majorForm = {};
    $scope.subjectForm = {};
    
    $scope.filterSubjectByDepartment = '';
    
    $scope.filterDepartmentByFaculty = '';
    $scope.filterMajorByFaculty = '';

    // Load all data on init
    $scope.init = function() {
        // 🔧 FIX: Close any stuck modal overlays
        if (typeof ModalUtils !== 'undefined') {
            ModalUtils.closeAll();
        }
        
        $scope.loadFaculties();
        $scope.loadDepartments();
        $scope.loadMajors();
        $scope.loadSubjects();
    };

    // =========================
    // FACULTY FUNCTIONS
    // =========================
    $scope.loadFaculties = function() {
        var params = PaginationService.buildQueryParams($scope.facultyPagination);
        
        FacultyService.getAll(params.page, params.pageSize, params.search)
            .then(function(response) {
                if (response.data.success) {
                    $scope.faculties = response.data.data;
                    $scope.facultyPagination.totalItems = response.data.totalCount;
                    $scope.facultyPagination = PaginationService.calculate($scope.facultyPagination);
                    
                    // Load stats for each faculty
                    $scope.faculties.forEach(function(faculty) {
                        $scope.loadFacultyStats(faculty);
                    });
                }
            })
            .catch(function(error) {
                ToastService.error('Lỗi khi tải danh sách khoa');
            });
    };

    $scope.loadFacultyStats = function(faculty) {
        // Count departments
        $http.get(API_CONFIG.BASE_URL + '/admin/department/faculty/' + faculty.facultyId)
            .then(function(response) {
                var departments = Array.isArray(response.data) ? response.data : 
                                 (response.data.data ? response.data.data : []);
                faculty.departmentCount = departments.length;
            })
            .catch(function(error) {
                faculty.departmentCount = 0;
            });
        
        // Count majors
        $http.get(API_CONFIG.BASE_URL + '/majors')
            .then(function(response) {
                var majors = Array.isArray(response.data) ? response.data : 
                            (response.data.data ? response.data.data : []);
                // Filter by faculty
                faculty.majorCount = majors.filter(function(m) {
                    return m.facultyId === faculty.facultyId;
                }).length;
            })
            .catch(function(error) {
                faculty.majorCount = 0;
            });
    };

    $scope.openFacultyModal = function() {
        $scope.facultyForm = { isActive: true };
        window.ModalUtils.open('facultyModal');
    };

    $scope.editFaculty = function(faculty) {
        $scope.facultyForm = angular.copy(faculty);
        window.ModalUtils.open('facultyModal');
    };

    $scope.saveFaculty = function() {
        if (!$scope.facultyForm.facultyCode || !$scope.facultyForm.facultyName) {
            ToastService.error('Vui lòng điền đầy đủ thông tin!');
            return;
        }

        var method = $scope.facultyForm.facultyId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/faculties';
        if (method === 'PUT') {
            url += '/' + $scope.facultyForm.facultyId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.facultyForm
        })
        .then(function(response) {
            ToastService.success(response.data?.message || 'Lưu thông tin Khoa thành công!');
            window.ModalUtils.close('facultyModal');
            $scope.loadFaculties();
            $scope.facultyForm = {};
        })
        .catch(function(error) {
            var errorMessage = 'Không thể lưu thông tin Khoa';
            
            // Try to extract error message from different response formats
            if (error.data) {
                if (error.data.message) {
                    errorMessage = error.data.message;
                } else if (error.data.errors) {
                    // Handle validation errors
                    var errors = [];
                    for (var key in error.data.errors) {
                        if (error.data.errors.hasOwnProperty(key)) {
                            errors.push(error.data.errors[key].join(', '));
                        }
                    }
                    errorMessage = errors.join('; ');
                } else if (typeof error.data === 'string') {
                    errorMessage = error.data;
                }
            }
            
            ToastService.error(errorMessage);
        });
    };

    $scope.deleteFaculty = function(facultyId) {
        if (!confirm('Bạn có chắc muốn xóa Khoa này?\nLưu ý: Sẽ ảnh hưởng đến Bộ môn và Ngành liên quan!')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/faculties/' + facultyId)
            .then(function(response) {
                ToastService.success(response.data?.message || 'Đã xóa Khoa thành công!');
                $scope.loadFaculties();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa Khoa');
            });
    };

    // =========================
    // DEPARTMENT FUNCTIONS
    // =========================
    $scope.loadDepartments = function() {
        $http.get(API_CONFIG.BASE_URL + '/admin/department')
            .then(function(response) {
                // Handle different response formats
                var data = response.data;
                if (data && data.data) {
                    $scope.departments = data.data;
                } else if (Array.isArray(data)) {
                    $scope.departments = data;
                } else {
                    $scope.departments = [];
                }
                
                // Load stats
                $scope.departments.forEach(function(dept) {
                    $scope.loadDepartmentStats(dept);
                });
            })
            .catch(function(error) {
                $scope.departments = [];
                ToastService.error('Lỗi khi tải danh sách bộ môn');
            });
    };

    $scope.loadDepartmentsByFaculty = function() {
        if (!$scope.filterDepartmentByFaculty) {
            $scope.loadDepartments();
            return;
        }

        $http.get(API_CONFIG.BASE_URL + '/admin/department/faculty/' + $scope.filterDepartmentByFaculty)
            .then(function(response) {
                // Handle different response formats
                var data = response.data;
                if (data && data.data) {
                    $scope.departments = data.data;
                } else if (Array.isArray(data)) {
                    $scope.departments = data;
                } else {
                    $scope.departments = [];
                }
                
                $scope.departments.forEach(function(dept) {
                    $scope.loadDepartmentStats(dept);
                });
            })
            .catch(function(error) {
                $scope.departments = [];
            });
    };

    $scope.loadDepartmentStats = function(dept) {
        // Count subjects
        $http.get(API_CONFIG.BASE_URL + '/subjects')
            .then(function(response) {
                // Filter subjects by department
                var subjects = Array.isArray(response.data) ? response.data : 
                              (response.data.data ? response.data.data : []);
                dept.subjectCount = subjects.filter(function(s) {
                    return s.departmentId === dept.departmentId;
                }).length;
            })
            .catch(function() {
                dept.subjectCount = 0;
            });
        
        // Count lecturers
        $http.get(API_CONFIG.BASE_URL + '/lecturers')
            .then(function(response) {
                var lecturers = Array.isArray(response.data) ? response.data : 
                               (response.data.data ? response.data.data : []);
                dept.lecturerCount = lecturers.filter(function(l) {
                    return l.departmentId === dept.departmentId;
                }).length;
            })
            .catch(function() {
                dept.lecturerCount = 0;
            });
    };

    $scope.openDepartmentModal = function() {
        $scope.departmentForm = { isActive: true };
        window.ModalUtils.open('departmentModal');
    };

    $scope.editDepartment = function(dept) {
        $scope.departmentForm = angular.copy(dept);
        window.ModalUtils.open('departmentModal');
    };

    $scope.saveDepartment = function() {
        if (!$scope.departmentForm.facultyId || !$scope.departmentForm.departmentName) {
            ToastService.error('Vui lòng điền đầy đủ thông tin!');
            return;
        }

        var method = $scope.departmentForm.departmentId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/admin/department';
        if (method === 'PUT') {
            url += '/' + $scope.departmentForm.departmentId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.departmentForm
        })
        .then(function(response) {
            ToastService.success(response.data?.message || 'Lưu thông tin Bộ môn thành công!');
            window.ModalUtils.close('departmentModal');
            $scope.loadDepartments();
            $scope.departmentForm = {};
        })
        .catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể lưu thông tin Bộ môn');
        });
    };

    $scope.deleteDepartment = function(departmentId) {
        if (!confirm('Bạn có chắc muốn xóa Bộ môn này?\nLưu ý: Sẽ ảnh hưởng đến Môn học và Giảng viên!')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/admin/department/' + departmentId)
            .then(function(response) {
                ToastService.success(response.data?.message || 'Đã xóa Bộ môn thành công!');
                $scope.loadDepartments();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa Bộ môn');
            });
    };

    // =========================
    // MAJOR FUNCTIONS
    // =========================
    $scope.loadMajors = function() {
        $http.get(API_CONFIG.BASE_URL + '/majors')
            .then(function(response) {
                // Handle different response formats
                var data = response.data;
                if (data && data.data) {
                    $scope.majors = data.data;
                } else if (Array.isArray(data)) {
                    $scope.majors = data;
                } else {
                    $scope.majors = [];
                }
            })
            .catch(function(error) {
                $scope.majors = [];
                ToastService.error('Lỗi khi tải danh sách ngành');
            });
    };

    $scope.loadMajorsByFaculty = function() {
        if (!$scope.filterMajorByFaculty) {
            $scope.loadMajors();
            return;
        }

        $http.get(API_CONFIG.BASE_URL + '/majors')
            .then(function(response) {
                // Handle different response formats
                var data = response.data;
                var allMajors = [];
                if (data && data.data) {
                    allMajors = data.data;
                } else if (Array.isArray(data)) {
                    allMajors = data;
                }
                
                // Filter by faculty
                $scope.majors = allMajors.filter(function(m) {
                    return m.facultyId === $scope.filterMajorByFaculty;
                });
            })
            .catch(function(error) {
                $scope.majors = [];
            });
    };

    $scope.openMajorModal = function() {
        $scope.majorForm = { isActive: true };
        window.ModalUtils.open('majorModal');
    };

    $scope.editMajor = function(major) {
        $scope.majorForm = angular.copy(major);
        window.ModalUtils.open('majorModal');
    };

    $scope.saveMajor = function() {
        if (!$scope.majorForm.facultyId || !$scope.majorForm.majorCode || 
            !$scope.majorForm.majorName) {
            ToastService.error('Vui lòng điền đầy đủ thông tin!');
            return;
        }

        var method = $scope.majorForm.majorId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/majors';
        if (method === 'PUT') {
            url += '/' + $scope.majorForm.majorId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.majorForm
        })
        .then(function(response) {
            ToastService.success(response.data?.message || 'Lưu thông tin Ngành thành công!');
            window.ModalUtils.close('majorModal');
            $scope.loadMajors();
            $scope.majorForm = {};
        })
        .catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể lưu thông tin Ngành');
        });
    };

    $scope.deleteMajor = function(majorId) {
        if (!confirm('Bạn có chắc muốn xóa Ngành này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/majors/' + majorId)
            .then(function(response) {
                ToastService.success(response.data?.message || 'Đã xóa Ngành thành công!');
                $scope.loadMajors();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa Ngành');
            });
    };

    // =========================
    // SUBJECT FUNCTIONS
    // =========================
    $scope.loadSubjects = function() {
        $http.get(API_CONFIG.BASE_URL + '/subjects')
            .then(function(response) {
                var data = response.data;
                if (data && data.data) {
                    $scope.subjects = data.data;
                } else if (Array.isArray(data)) {
                    $scope.subjects = data;
                } else {
                    $scope.subjects = [];
                }
                // Ensure array
                if (!Array.isArray($scope.subjects)) {
                    $scope.subjects = [];
                }
            })
            .catch(function(error) {
                $scope.subjects = [];
                ToastService.error('Lỗi khi tải danh sách môn học');
            });
    };

    $scope.loadSubjectsByDepartment = function() {
        if (!$scope.filterSubjectByDepartment) {
            $scope.loadSubjects();
            return;
        }

        $http.get(API_CONFIG.BASE_URL + '/subjects/by-department/' + $scope.filterSubjectByDepartment)
            .then(function(response) {
                var data = response.data;
                if (data && data.data) {
                    $scope.subjects = data.data;
                } else if (Array.isArray(data)) {
                    $scope.subjects = data;
                } else {
                    $scope.subjects = [];
                }
            })
            .catch(function(error) {
                $scope.subjects = [];
            });
    };

    $scope.openSubjectModal = function() {
        $scope.subjectForm = { credits: 3 };
        window.ModalUtils.open('subjectModal');
    };

    $scope.editSubject = function(subject) {
        $scope.subjectForm = angular.copy(subject);
        window.ModalUtils.open('subjectModal');
    };

    $scope.saveSubject = function() {
        if (!$scope.subjectForm.subjectCode || !$scope.subjectForm.subjectName || 
            !$scope.subjectForm.departmentId) {
            ToastService.error('Vui lòng điền đầy đủ thông tin!');
            return;
        }

        var method = $scope.subjectForm.subjectId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/subjects';
        if (method === 'PUT') {
            url += '/' + $scope.subjectForm.subjectId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.subjectForm
        })
        .then(function(response) {
            ToastService.success(response.data?.message || 'Lưu thông tin Môn học thành công!');
            window.ModalUtils.close('subjectModal');
            $scope.loadSubjects();
            $scope.subjectForm = {};
        })
        .catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể lưu thông tin Môn học');
        });
    };

    $scope.deleteSubject = function(subjectId) {
        if (!confirm('Bạn có chắc muốn xóa Môn học này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/subjects/' + subjectId)
            .then(function(response) {
                ToastService.success(response.data?.message || 'Đã xóa Môn học thành công!');
                $scope.loadSubjects();
            })
            .catch(function(error) {
                ToastService.error(error.data?.message || 'Không thể xóa Môn học');
            });
    };

    // =========================
    // INITIALIZE
    // =========================
    // Call init after all functions are defined
    $scope.init();
}]);

