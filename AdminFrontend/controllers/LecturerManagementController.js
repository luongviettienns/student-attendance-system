// ============================================================
// LECTURER MANAGEMENT CONTROLLER - Quản lý Giảng viên + Phân môn
// ============================================================
app.controller('LecturerManagementController', ['$scope', '$http', 'API_CONFIG', 'AuthService', 'AvatarService', 'RoleService', 'ToastService', 'LoggerService', 'DepartmentService',
    function($scope, $http, API_CONFIG, AuthService, AvatarService, RoleService, ToastService, LoggerService, DepartmentService) {
    
    // =========================
    // INITIALIZATION
    // =========================
    $scope.activeTab = 'lecturers';
    $scope.lecturers = [];
    $scope.departments = [];
    $scope.allSubjects = [];
    $scope.lecturerForm = {};
    $scope.filterByDepartment = '';
    
    // For subject assignment
    $scope.selectedLecturer = {};
    $scope.lecturerSubjects = [];
    $scope.availableSubjects = [];
    $scope.newSubject = {};
    
    // Pagination for subjects list
    $scope.subjectsCurrentPage = 1;
    $scope.subjectsPageSize = 5; // 5 môn học mỗi trang
    $scope.subjectsTotalPages = 1;
    $scope.paginatedSubjects = [];
    
    // Permission check
    $scope.canViewSubjectAssignment = false;

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

    // Handle tab click
    $scope.onTabClick = function(tabName) {
        LoggerService.debug('Lecturer management tab clicked', tabName);
        $scope.activeTab = tabName;
        LoggerService.debug('Lecturer management active tab', $scope.activeTab);
    };
    
    $scope.init = function() {
        // Load permissions first, then load data
        RoleService.loadPermissions().then(function() {
            $scope.canViewSubjectAssignment = RoleService.hasPermission('canManageLecturers');
            LoggerService.debug('Permissions loaded for lecturer management', { canViewSubjectAssignment: $scope.canViewSubjectAssignment });
            
            // Now load data
            $scope.loadLecturers();
            $scope.loadDepartments();
            
            // Only load subjects if has permission
            if ($scope.canViewSubjectAssignment) {
                $scope.loadAllSubjects();
            }
        }).catch(function(error) {
            LoggerService.error('Error loading lecturer permissions', error);
            // Use fallback permissions
            $scope.canViewSubjectAssignment = RoleService.hasPermission('canManageLecturers');
            
            // Still load basic data
            $scope.loadLecturers();
            $scope.loadDepartments();
            
            if ($scope.canViewSubjectAssignment) {
                $scope.loadAllSubjects();
            }
        });
    };

    // =========================
    // LECTURER FUNCTIONS
    // =========================
    $scope.loadLecturers = function() {
        $http.get(API_CONFIG.BASE_URL + '/lecturers')
            .then(function(response) {
                $scope.lecturers = response.data;
                
                // Load subject count for each lecturer (only if has permission)
                if ($scope.canViewSubjectAssignment) {
                    $scope.lecturers.forEach(function(lecturer) {
                        $scope.loadLecturerSubjectCount(lecturer);
                    });
                }
            })
            .catch(function(error) {
                ToastService.error('❌ Lỗi tải danh sách giảng viên');
            });
    };

    $scope.loadLecturersByDepartment = function() {
        if (!$scope.filterByDepartment) {
            $scope.loadLecturers();
            return;
        }

        $http.get(API_CONFIG.BASE_URL + '/lecturers')
            .then(function(response) {
                $scope.lecturers = response.data.filter(function(l) {
                    return l.departmentId === $scope.filterByDepartment;
                });

                // Load subject count (only if has permission)
                if ($scope.canViewSubjectAssignment) {
                    $scope.lecturers.forEach(function(lecturer) {
                        $scope.loadLecturerSubjectCount(lecturer);
                    });
                }
            })
            .catch(function(error) {
                ToastService.error('❌ Lỗi tải danh sách giảng viên');
            });
    };

    $scope.loadLecturerSubjectCount = function(lecturer) {
        $http.get(API_CONFIG.BASE_URL + '/lecturer-subjects/lecturer/' + lecturer.lecturerId)
            .then(function(response) {
                lecturer.subjectCount = (response.data.data || []).length;
            })
            .catch(function() {
                lecturer.subjectCount = 0;
            });
    };

    $scope.loadDepartments = function() {
        DepartmentService.getAll()
            .then(function(response) {
                // Handle different response formats: {data: [...]} or [...]
                var data = response.data;
                if (data && data.data && Array.isArray(data.data)) {
                    $scope.departments = data.data;
                } else if (Array.isArray(data)) {
                    $scope.departments = data;
                } else {
                    $scope.departments = [];
                }
                LoggerService.debug('Departments loaded', { count: $scope.departments.length });
            })
            .catch(function(error) {
                LoggerService.error('Error loading departments', error);
                ToastService.error('❌ Lỗi tải danh sách bộ môn');
                $scope.departments = [];
            });
    };

    $scope.openLecturerModal = function() {
        $scope.lecturerForm = { isActive: true };
        ModalUtils.open('lecturerModal');
    };

    $scope.editLecturer = function(lecturer) {
        $scope.lecturerForm = angular.copy(lecturer);
        ModalUtils.open('lecturerModal');
    };

    $scope.saveLecturer = function() {
        if (!$scope.lecturerForm.fullName || !$scope.lecturerForm.email || 
            !$scope.lecturerForm.departmentId) {
            ToastService.warning('⚠️ Vui lòng điền đầy đủ thông tin bắt buộc!');
            return;
        }

        var method = $scope.lecturerForm.lecturerId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/lecturers';
        if (method === 'PUT') {
            url += '/' + $scope.lecturerForm.lecturerId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.lecturerForm
        })
        .then(function(response) {
            ToastService.success('✅ Lưu thông tin Giảng viên thành công!');
            ModalUtils.close('lecturerModal');
            $scope.loadLecturers();
            $scope.lecturerForm = {};
        })
        .catch(function(error) {
            var errorMsg = error.data?.message || 'Không thể lưu thông tin Giảng viên';
            ToastService.error('❌ Lỗi: ' + errorMsg);
        });
    };

    $scope.deleteLecturer = function(lecturerId) {
        if (!confirm('Bạn có chắc muốn xóa Giảng viên này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/lecturers/' + lecturerId)
            .then(function(response) {
                ToastService.success('🗑 Đã xóa Giảng viên!');
                $scope.loadLecturers();
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Không thể xóa Giảng viên';
                ToastService.error('❌ Lỗi: ' + errorMsg);
            });
    };

    // =========================
    // SUBJECT ASSIGNMENT FUNCTIONS
    // =========================
    $scope.loadAllSubjects = function() {
        $http.get(API_CONFIG.BASE_URL + '/subjects')
            .then(function(response) {
                $scope.allSubjects = response.data;
                
                // Load assigned lecturers for each subject
                $scope.allSubjects.forEach(function(subject) {
                    $scope.loadSubjectLecturers(subject);
                });
                
                // Update pagination
                $scope.updateSubjectsPagination();
            })
            .catch(function(error) {
                ToastService.error('❌ Lỗi tải danh sách môn học');
            });
    };
    
    // Pagination functions for subjects list
    $scope.updateSubjectsPagination = function() {
        $scope.subjectsTotalPages = Math.ceil($scope.allSubjects.length / $scope.subjectsPageSize);
        if ($scope.subjectsCurrentPage > $scope.subjectsTotalPages && $scope.subjectsTotalPages > 0) {
            $scope.subjectsCurrentPage = $scope.subjectsTotalPages;
        }
        $scope.updatePaginatedSubjects();
    };
    
    $scope.updatePaginatedSubjects = function() {
        var start = ($scope.subjectsCurrentPage - 1) * $scope.subjectsPageSize;
        var end = start + $scope.subjectsPageSize;
        $scope.paginatedSubjects = $scope.allSubjects.slice(start, end);
    };
    
    $scope.goToSubjectsPage = function(page) {
        if (page >= 1 && page <= $scope.subjectsTotalPages) {
            $scope.subjectsCurrentPage = page;
            $scope.updatePaginatedSubjects();
        }
    };
    
    $scope.previousSubjectsPage = function() {
        if ($scope.subjectsCurrentPage > 1) {
            $scope.subjectsCurrentPage--;
            $scope.updatePaginatedSubjects();
        }
    };
    
    $scope.nextSubjectsPage = function() {
        if ($scope.subjectsCurrentPage < $scope.subjectsTotalPages) {
            $scope.subjectsCurrentPage++;
            $scope.updatePaginatedSubjects();
        }
    };
    
    $scope.getSubjectsPages = function() {
        var pages = [];
        var startPage = Math.max(1, $scope.subjectsCurrentPage - 2);
        var endPage = Math.min($scope.subjectsTotalPages, $scope.subjectsCurrentPage + 2);
        
        for (var i = startPage; i <= endPage; i++) {
            pages.push(i);
        }
        return pages;
    };

    $scope.loadSubjectLecturers = function(subject) {
        $http.get(API_CONFIG.BASE_URL + '/lecturer-subjects/subject/' + subject.subjectId)
            .then(function(response) {
                subject.assignedLecturers = response.data.data || [];
            })
            .catch(function() {
                subject.assignedLecturers = [];
            });
    };

    $scope.assignSubjects = function(lecturer) {
        $scope.selectedLecturer = lecturer;
        $scope.newSubject = { isPrimary: false, experienceYears: 0 };
        
        // Load subjects assigned to this lecturer
        $http.get(API_CONFIG.BASE_URL + '/lecturer-subjects/lecturer/' + lecturer.lecturerId)
            .then(function(response) {
                $scope.lecturerSubjects = response.data.data || [];
                
                // Get available subjects (not yet assigned)
                var assignedSubjectIds = $scope.lecturerSubjects.map(function(ls) {
                    return ls.subjectId;
                });
                
                $scope.availableSubjects = $scope.allSubjects.filter(function(s) {
                    return assignedSubjectIds.indexOf(s.subjectId) === -1;
                });
                
                ModalUtils.open('assignSubjectsModal');
            })
            .catch(function(error) {
                ToastService.error('❌ Lỗi tải môn học của giảng viên');
            });
    };

    $scope.addSubjectToLecturer = function() {
        if (!$scope.newSubject.subjectId) {
            ToastService.warning('⚠️ Vui lòng chọn môn học!');
            return;
        }

        var data = {
            lecturerId: $scope.selectedLecturer.lecturerId,
            subjectId: $scope.newSubject.subjectId,
            isPrimary: $scope.newSubject.isPrimary || false,
            experienceYears: $scope.newSubject.experienceYears || 0,
            notes: $scope.newSubject.notes || '',
            certifiedDate: new Date().toISOString()
        };

        $http.post(API_CONFIG.BASE_URL + '/lecturer-subjects', data)
            .then(function(response) {
                ToastService.success('✅ Đã phân môn cho giảng viên!');
                $scope.assignSubjects($scope.selectedLecturer); // Reload
                $scope.newSubject = { isPrimary: false, experienceYears: 0 };
                $scope.loadLecturers(); // Update count
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Không thể phân môn';
                ToastService.error('❌ Lỗi: ' + errorMsg);
            });
    };

    $scope.removeSubject = function(lecturerSubjectId) {
        if (!confirm('Bạn có chắc muốn bỏ môn này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/lecturer-subjects/' + lecturerSubjectId)
            .then(function(response) {
                ToastService.success('🗑 Đã bỏ môn học!');
                $scope.assignSubjects($scope.selectedLecturer); // Reload
                $scope.loadLecturers(); // Update count
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Không thể bỏ môn';
                ToastService.error('❌ Lỗi: ' + errorMsg);
            });
    };

    $scope.viewLecturerSubjects = function(lecturer) {
        $scope.assignSubjects(lecturer);
    };

    // Initialize on load
    $scope.init();
}]);

