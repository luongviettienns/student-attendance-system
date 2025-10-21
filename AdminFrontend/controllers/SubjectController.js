// Subject Controller
app.controller('SubjectController', ['$scope', '$location', '$routeParams', 'SubjectService', 'DepartmentService',
    function($scope, $location, $routeParams, SubjectService, DepartmentService) {
    
    $scope.subjects = [];
    $scope.filteredSubjects = [];
    $scope.subject = {};
    $scope.departments = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    $scope.filterByDepartment = '';
    
    // Load all subjects
    $scope.loadSubjects = function() {
        $scope.loading = true;
        SubjectService.getAll()
            .then(function(response) {
                $scope.subjects = response.data;
                $scope.filteredSubjects = $scope.subjects;
                
                // Load lecturer count for each subject
                $scope.subjects.forEach(function(subject) {
                    $scope.loadSubjectLecturerCount(subject);
                });
                
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách môn học';
                $scope.loading = false;
            });
    };
    
    // Load lecturer count for subject
    $scope.loadSubjectLecturerCount = function(subject) {
        SubjectService.getLecturersBySubject(subject.subjectId)
            .then(function(response) {
                subject.lecturerCount = response.data.length;
            })
            .catch(function() {
                subject.lecturerCount = 0;
            });
    };
    
    // Filter subjects by department
    $scope.filterSubjects = function() {
        if (!$scope.filterByDepartment) {
            $scope.filteredSubjects = $scope.subjects;
        } else {
            $scope.filteredSubjects = $scope.subjects.filter(function(s) {
                return s.departmentId === $scope.filterByDepartment;
            });
        }
    };
    
    // Load subject by ID for editing
    $scope.loadSubject = function(id) {
        $scope.loading = true;
        SubjectService.getById(id)
            .then(function(response) {
                $scope.subject = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin môn học';
                $scope.loading = false;
            });
    };
    
    // Create or update subject
    $scope.saveSubject = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = SubjectService.update($scope.subject.subjectId, $scope.subject);
        } else {
            savePromise = SubjectService.create($scope.subject);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu môn học thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/subjects');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu môn học';
                $scope.loading = false;
            });
    };
    
    // Delete subject
    $scope.deleteSubject = function(subjectId) {
        if (!confirm('Bạn có chắc chắn muốn xóa môn học này?')) {
            return;
        }
        
        SubjectService.delete(subjectId)
            .then(function(response) {
                $scope.success = 'Xóa môn học thành công';
                $scope.loadSubjects();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa môn học';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/subjects/create');
    };
    
    $scope.goToEdit = function(subjectId) {
        $location.path('/subjects/edit/' + subjectId);
    };
    
    $scope.cancel = function() {
        $location.path('/subjects');
    };
    
    // ============================================================
    // 🔹 Load danh sách bộ môn (cho dropdown)
    // ============================================================
    $scope.loadDepartments = function() {
        DepartmentService.getAll()
            .then(function(response) {
                $scope.departments = response.data;
            })
            .catch(function(error) {
                console.error('Lỗi khi tải danh sách bộ môn:', error);
            });
    };
    
    // Initialize based on route
    if ($location.path() === '/subjects') {
        $scope.loadSubjects();
        $scope.loadDepartments(); // Load departments for filter
    } else if ($routeParams.id) {
        $scope.loadDepartments();
        $scope.loadSubject($routeParams.id);
    } else if ($location.path() === '/subjects/create') {
        $scope.loadDepartments();
    }
}]);

