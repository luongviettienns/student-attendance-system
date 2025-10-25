// Class Management Controller
app.controller('ClassController', ['$scope', '$location', '$routeParams', 'ClassService', 'SubjectService', 'LecturerService', 'AcademicYearService', 'AuthService', 'AvatarService',
    function($scope, $location, $routeParams, ClassService, SubjectService, LecturerService, AcademicYearService, AuthService, AvatarService) {
    
    $scope.classes = [];
    $scope.displayedClasses = [];
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
    
    // Load classes
    $scope.loadClasses = function() {
        $scope.loading = true;
        
        ClassService.getAll()
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.classes = response.data.data.map(function(classItem) {
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
                    
                    $scope.displayedClasses = $scope.classes;
                } else {
                    $scope.classes = [];
                    $scope.displayedClasses = [];
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading classes:', error);
                console.error('Error details:', {
                    status: error.status,
                    statusText: error.statusText,
                    data: error.data,
                    message: error.message
                });
                $scope.error = 'Không thể tải danh sách lớp học: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                $scope.loading = false;
            });
    };
    
    // Load subjects for dropdown
    $scope.subjects = [];
    $scope.loadSubjects = function() {
        SubjectService.getAll()
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.subjects = response.data.data;
                }
            })
            .catch(function(error) {
                console.error('Error loading subjects:', error);
            });
    };
    
    // Load lecturers for dropdown
    $scope.lecturers = [];
    $scope.loadLecturers = function() {
        LecturerService.getAll()
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.lecturers = response.data.data;
                }
            })
            .catch(function(error) {
                console.error('Error loading lecturers:', error);
            });
    };
    
    // Load academic years for dropdown
    $scope.academicYears = [];
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll()
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.academicYears = response.data.data;
                }
            })
            .catch(function(error) {
                console.error('Error loading academic years:', error);
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
            createdBy: AuthService.getCurrentUser()?.userId || 'system'
        };
        
        ClassService.create(classData)
            .then(function(response) {
                $scope.success = 'Tạo lớp học thành công';
                $scope.closeFormModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                console.error('Error creating class:', error);
                $scope.error = 'Không thể tạo lớp học: ' + (error.data?.message || error.message);
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
            updatedBy: AuthService.getCurrentUser()?.userId || 'system'
        };
        
        ClassService.update($scope.selectedClass.classId, classData)
            .then(function(response) {
                $scope.success = 'Cập nhật lớp học thành công';
                $scope.closeFormModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                console.error('Error updating class:', error);
                $scope.error = 'Không thể cập nhật lớp học: ' + (error.data?.message || error.message);
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
        var deleteData = {
            deletedBy: AuthService.getCurrentUser()?.userId || 'system'
        };
        
        ClassService.delete($scope.selectedClass.classId, deleteData)
            .then(function(response) {
                $scope.success = 'Xóa lớp học thành công';
                $scope.closeDeleteModal();
                $scope.loadClasses();
            })
            .catch(function(error) {
                console.error('Error deleting class:', error);
                $scope.error = 'Không thể xóa lớp học: ' + (error.data?.message || error.message);
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