// Lecturer Controller
app.controller('LecturerController', ['$scope', '$location', '$routeParams', 'LecturerService', 'DepartmentService', 'SubjectService', 'LecturerSubjectService',
    function($scope, $location, $routeParams, LecturerService, DepartmentService, SubjectService, LecturerSubjectService) {
    
    $scope.lecturers = [];
    $scope.lecturer = {};
    $scope.departments = [];
    $scope.allSubjects = [];
    $scope.assignedSubjects = [];
    $scope.newAssignment = {};
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.isEditMode = false;
    
    // Load all lecturers
    $scope.loadLecturers = function() {
        $scope.loading = true;
        LecturerService.getAll()
            .then(function(response) {
                $scope.lecturers = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách giảng viên';
                $scope.loading = false;
            });
    };
    
    // Load lecturer by ID for editing
    $scope.loadLecturer = function(id) {
        $scope.loading = true;
        LecturerService.getById(id)
            .then(function(response) {
                $scope.lecturer = response.data;
                $scope.isEditMode = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải thông tin giảng viên';
                $scope.loading = false;
            });
    };
    
    // Create or update lecturer
    $scope.saveLecturer = function() {
        $scope.error = null;
        $scope.loading = true;
        
        var savePromise;
        if ($scope.isEditMode) {
            savePromise = LecturerService.update($scope.lecturer.lecturerId, $scope.lecturer);
        } else {
            savePromise = LecturerService.create($scope.lecturer);
        }
        
        savePromise
            .then(function(response) {
                $scope.success = 'Lưu giảng viên thành công';
                $scope.loading = false;
                setTimeout(function() {
                    $location.path('/lecturers');
                    $scope.$apply();
                }, 1500);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể lưu giảng viên';
                $scope.loading = false;
            });
    };
    
    // Delete lecturer
    $scope.deleteLecturer = function(lecturerId) {
        if (!confirm('Bạn có chắc chắn muốn xóa giảng viên này?')) {
            return;
        }
        
        LecturerService.delete(lecturerId)
            .then(function(response) {
                $scope.success = 'Xóa giảng viên thành công';
                $scope.loadLecturers();
            })
            .catch(function(error) {
                $scope.error = 'Không thể xóa giảng viên';
            });
    };
    
    // Navigation
    $scope.goToCreate = function() {
        $location.path('/lecturers/create');
    };
    
    $scope.goToEdit = function(lecturerId) {
        $location.path('/lecturers/edit/' + lecturerId);
    };
    
    $scope.cancel = function() {
        $location.path('/lecturers');
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
    
    // ============================================================
    // 🔹 Load danh sách môn học (cho phân môn)
    // ============================================================
    $scope.loadAllSubjects = function() {
        SubjectService.getAll()
            .then(function(response) {
                $scope.allSubjects = response.data;
            })
            .catch(function(error) {
                console.error('Lỗi khi tải danh sách môn học:', error);
            });
    };
    
    // ============================================================
    // 🔹 Load môn học đã phân cho giảng viên
    // ============================================================
    $scope.loadAssignedSubjects = function(lecturerId) {
        LecturerSubjectService.getSubjectsByLecturer(lecturerId)
            .then(function(response) {
                $scope.assignedSubjects = response.data;
            })
            .catch(function(error) {
                console.error('Lỗi khi tải môn học đã phân:', error);
            });
    };
    
    // ============================================================
    // 🔹 Phân môn mới cho giảng viên
    // ============================================================
    $scope.assignNewSubject = function() {
        if (!$scope.newAssignment.subjectId) {
            $scope.error = 'Vui lòng chọn môn học';
            return;
        }
        
        var assignment = {
            lecturerId: $scope.lecturer.lecturerId,
            subjectId: $scope.newAssignment.subjectId,
            isPrimary: $scope.newAssignment.isPrimary || false,
            certifiedDate: $scope.newAssignment.certifiedDate || null,
            experienceYears: $scope.newAssignment.experienceYears || null,
            notes: $scope.newAssignment.notes || null
        };
        
        LecturerSubjectService.assignSubject(assignment)
            .then(function(response) {
                $scope.success = 'Phân môn thành công';
                $scope.newAssignment = {};
                $scope.loadAssignedSubjects($scope.lecturer.lecturerId);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể phân môn';
            });
    };
    
    // ============================================================
    // 🔹 Xóa phân môn
    // ============================================================
    $scope.removeSubjectAssignment = function(assignmentId, subjectName) {
        if (!confirm('Bạn có chắc chắn muốn xóa phân môn "' + subjectName + '"?')) {
            return;
        }
        
        LecturerSubjectService.delete(assignmentId)
            .then(function(response) {
                $scope.success = 'Xóa phân môn thành công';
                $scope.loadAssignedSubjects($scope.lecturer.lecturerId);
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể xóa phân môn';
            });
    };
    
    // Initialize based on route
    if ($location.path() === '/lecturers') {
        $scope.loadLecturers();
    } else if ($routeParams.id) {
        $scope.loadDepartments();
        $scope.loadAllSubjects();
        $scope.loadLecturer($routeParams.id);
        $scope.loadAssignedSubjects($routeParams.id);
    } else if ($location.path() === '/lecturers/create') {
        $scope.loadDepartments();
        $scope.lecturer.isActive = true;
    }
}]);

