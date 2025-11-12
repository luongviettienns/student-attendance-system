// Class Management Controller
app.controller('ClassController', ['$scope', '$location', '$routeParams', 'ClassService', 'SubjectService', 'LecturerService', 'AcademicYearService', 'AuthService', 'AvatarService', 'LoggerService', 'PaginationService',
    function($scope, $location, $routeParams, ClassService, SubjectService, LecturerService, AcademicYearService, AuthService, AvatarService, LoggerService, PaginationService) {
    
    $scope.classes = [];
    $scope.displayedClasses = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    $scope.currentUser = null;
    
    // Pagination
    $scope.pagination = PaginationService.init(10);
    
    // Initialize page
    $scope.initPage = function() {
        $scope.currentUser = AuthService.getCurrentUser();
        
        // Initialize sidebar toggle
        var menuToggle = document.getElementById('menuToggle');
        if (menuToggle) {
            // Store handler reference for cleanup
            $scope.menuToggleHandler = function() {
                var sidebar = document.querySelector('.sidebar');
                var mainContent = document.querySelector('.main-content');
                if (sidebar && mainContent) {
                    sidebar.classList.toggle('collapsed');
                    mainContent.classList.toggle('expanded');
                }
            };
            
            menuToggle.addEventListener('click', $scope.menuToggleHandler);
        }
    };
    
    // Cleanup event listeners on controller destroy
    $scope.$on('$destroy', function() {
        var menuToggle = document.getElementById('menuToggle');
        if (menuToggle && $scope.menuToggleHandler) {
            menuToggle.removeEventListener('click', $scope.menuToggleHandler);
        }
    });
    
    // Get initial for avatar
    $scope.getInitial = function(user) {
        if (user && user.fullName) {
            return user.fullName.charAt(0).toUpperCase();
        }
        return 'U';
    };
    
    // Clear messages
    $scope.clearMessage = function() {
        $scope.success = null;
        $scope.error = null;
    };
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Open Avatar Modal
    $scope.openAvatarModal = function() {
        if (AvatarService && AvatarService.openModal) {
            AvatarService.openModal();
        }
    };
    
    // Get current user for header
    $scope.getCurrentUser = function() {
        return $scope.currentUser || AuthService.getCurrentUser();
    };
    
    // Logout function
    $scope.logout = function() {
        AuthService.logout(); // Will auto-redirect to login
    };
    
    // Filters
    $scope.filters = {
        subjectId: '',
        lecturerId: '',
        academicYearId: '',
        semester: ''
    };
    
    // Semester options
    $scope.semesters = [
        { value: '1', label: 'Học kỳ 1' },
        { value: '2', label: 'Học kỳ 2' },
        { value: '3', label: 'Học kỳ hè' }
    ];
    
    // Load classes with server-side pagination
    $scope.loadClasses = function() {
        $scope.loading = true;
        $scope.error = null;
        
        var params = {
            page: $scope.pagination.currentPage,
            pageSize: $scope.pagination.pageSize,
            search: $scope.pagination.searchTerm || null,
            subjectId: $scope.filters.subjectId || null,
            lecturerId: $scope.filters.lecturerId || null,
            academicYearId: $scope.filters.academicYearId || null
        };
        
        // Remove empty values
        Object.keys(params).forEach(function(key) {
            if (params[key] === null || params[key] === '' || params[key] === undefined) {
                delete params[key];
            }
        });
        
        ClassService.getAll(params)
            .then(function(response) {
                LoggerService.debug('Classes response received', response);
                LoggerService.debug('Classes response payload', response.data);
                
                var result = response.data;
                
                if (result && result.data) {
                    $scope.displayedClasses = result.data.map(function(classItem) {
                        return {
                            classId: classItem.classId,
                            classCode: classItem.classCode,
                            className: classItem.className,
                            subjectId: classItem.subjectId,
                            subjectName: classItem.subjectName || 'N/A',
                            lecturerId: classItem.lecturerId,
                            lecturerName: classItem.lecturerName || 'N/A',
                            semester: classItem.semester,
                            academicYearId: classItem.academicYearId,
                            academicYearName: classItem.academicYearName || 'N/A',
                            maxStudents: classItem.maxStudents,
                            currentStudents: classItem.currentStudents || 0,
                            createdAt: classItem.createdAt,
                            updatedAt: classItem.updatedAt
                        };
                    });
                    
                    $scope.classes = $scope.displayedClasses;
                    
                    // Update pagination info from server
                    if (result.totalCount !== undefined) {
                        $scope.pagination.totalItems = result.totalCount;
                        $scope.pagination.totalPages = result.totalPages;
                        $scope.pagination.currentPage = result.page;
                        $scope.pagination.pageSize = result.pageSize;
                    }
                    
                    // Recalculate pagination UI
                    $scope.pagination = PaginationService.calculate($scope.pagination);
                    
                    LoggerService.debug('Classes loaded', { total: $scope.classes.length });
                } else {
                    $scope.classes = [];
                    $scope.displayedClasses = [];
                    LoggerService.warn('No classes data found for the current filters.');
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                LoggerService.error('Error loading classes', error);
                $scope.error = 'Không thể tải danh sách lớp học: ' + (error.data && error.data.message || error.message || 'Lỗi không xác định');
                $scope.loading = false;
            });
    };
    
    // Search handler
    $scope.handleSearch = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadClasses();
    };
    
    // Filter handler
    $scope.handleFilter = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadClasses();
    };
    
    // Page change handler
    $scope.handlePageChange = function(page) {
        $scope.pagination.currentPage = page;
        $scope.loadClasses();
    };
    
    // Page size change handler
    $scope.handlePageSizeChange = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadClasses();
    };
    
    // Load subjects for dropdown
    $scope.subjects = [];
    $scope.loadSubjects = function() {
        SubjectService.getAll()
            .then(function(response) {
                if (response.data) {
                    $scope.subjects = response.data;
                }
            })
            .catch(function(error) {
                LoggerService.error('Error loading subjects', error);
            });
    };
    
    // Load lecturers for dropdown
    $scope.lecturers = [];
    $scope.loadLecturers = function() {
        LecturerService.getAll()
            .then(function(response) {
                if (response.data) {
                    $scope.lecturers = response.data;
                }
            })
            .catch(function(error) {
                LoggerService.error('Error loading lecturers', error);
            });
    };
    
    // Load academic years for dropdown
    $scope.academicYears = [];
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll()
            .then(function(response) {
                       if (response.data) {
                           $scope.academicYears = response.data;
                }
            })
            .catch(function(error) {
                // Error handled silently
            });
    };
    
    // View mode
    $scope.showFormModal = false;
    $scope.showDeleteModal = false;
    $scope.selectedClass = {};
    $scope.formMode = 'create'; // 'create' or 'edit'
    
    // Open create form
    $scope.openCreateForm = function() {
        $scope.formMode = 'create';
        $scope.selectedClass = {
            classCode: '',
            className: '',
            subjectId: '',
            lecturerId: '',
            semester: '1',
            academicYearId: '',
            maxStudents: 50
        };
        $scope.showFormModal = true;
    };
    
    // Open edit form
    $scope.openEditForm = function(classItem) {
        $scope.formMode = 'edit';
        $scope.selectedClass = angular.copy(classItem);
        $scope.showFormModal = true;
    };
    
    // Close form modal
    $scope.closeFormModal = function() {
        $scope.showFormModal = false;
        $scope.selectedClass = {};
    };
    
    // Save class
    $scope.saveClass = function() {
        if ($scope.formMode === 'create') {
            $scope.createClass();
        } else {
            $scope.updateClass();
        }
    };
    
    // Create class
    $scope.createClass = function() {
        var classData = {
            classCode: $scope.selectedClass.classCode,
            className: $scope.selectedClass.className,
            subjectId: $scope.selectedClass.subjectId,
            lecturerId: $scope.selectedClass.lecturerId,
            semester: $scope.selectedClass.semester,
            academicYearId: $scope.selectedClass.academicYearId,
            maxStudents: $scope.selectedClass.maxStudents,
            createdBy: (AuthService.getCurrentUser() && AuthService.getCurrentUser().userId) || 'system'
        };
        
        ClassService.create(classData)
            .then(function(response) {
                $scope.success = 'Tạo lớp học thành công';
                $scope.closeFormModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                $scope.error = 'Không thể tạo lớp học: ' + (error.data && error.data.message || error.message || 'Lỗi không xác định');
            });
    };
    
    // Update class
    $scope.updateClass = function() {
        var classData = {
            classCode: $scope.selectedClass.classCode,
            className: $scope.selectedClass.className,
            subjectId: $scope.selectedClass.subjectId,
            lecturerId: $scope.selectedClass.lecturerId,
            semester: $scope.selectedClass.semester,
            academicYearId: $scope.selectedClass.academicYearId,
            maxStudents: $scope.selectedClass.maxStudents,
            updatedBy: (AuthService.getCurrentUser() && AuthService.getCurrentUser().userId) || 'system'
        };
        
        ClassService.update($scope.selectedClass.classId, classData)
            .then(function(response) {
                $scope.success = 'Cập nhật lớp học thành công';
                $scope.closeFormModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                $scope.error = 'Không thể cập nhật lớp học: ' + (error.data && error.data.message || error.message || 'Lỗi không xác định');
            });
    };
    
    // Open delete modal
    $scope.openDeleteModal = function(classItem) {
        $scope.selectedClass = angular.copy(classItem);
        $scope.showDeleteModal = true;
    };
    
    // Close delete modal
    $scope.closeDeleteModal = function() {
        $scope.showDeleteModal = false;
        $scope.selectedClass = {};
    };
    
    // Delete class
    $scope.deleteClass = function() {
        ClassService.delete($scope.selectedClass.classId)
            .then(function(response) {
                $scope.success = 'Xóa lớp học thành công';
                $scope.closeDeleteModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa lớp học: ' + (error.data && error.data.message || error.message || 'Lỗi không xác định');
            });
    };
    
    // Get semester label
    $scope.getSemesterLabel = function(semester) {
        var semesterObj = $scope.semesters.find(function(s) {
            return s.value === semester;
        });
        return semesterObj ? semesterObj.label : semester;
    };
    
    // Format date
    $scope.formatDate = function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        return date.toLocaleString('vi-VN');
    };
    
    // Initialize
    $scope.loadClasses();
    $scope.loadSubjects();
    $scope.loadLecturers();
    $scope.loadAcademicYears();
}]);