// ============================================================
// LECTURER MANAGEMENT CONTROLLER - Quản lý Giảng viên + Phân môn
// ============================================================
app.controller('LecturerManagementController', ['$scope', '$http', 'API_CONFIG', 'AuthService', 'AvatarService', function($scope, $http, API_CONFIG, AuthService, AvatarService) {
    
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

    $scope.init = function() {
        $scope.loadLecturers();
        $scope.loadDepartments();
        $scope.loadAllSubjects();
    };

    // =========================
    // LECTURER FUNCTIONS
    // =========================
    $scope.loadLecturers = function() {
        $http.get(API_CONFIG.BASE_URL + '/lecturer')
            .then(function(response) {
                $scope.lecturers = response.data;
                
                // Load subject count for each lecturer
                $scope.lecturers.forEach(function(lecturer) {
                    $scope.loadLecturerSubjectCount(lecturer);
                });
            })
            .catch(function(error) {
                console.error('Error loading lecturers:', error);
            });
    };

    $scope.loadLecturersByDepartment = function() {
        if (!$scope.filterByDepartment) {
            $scope.loadLecturers();
            return;
        }

        $http.get(API_CONFIG.BASE_URL + '/lecturer')
            .then(function(response) {
                $scope.lecturers = response.data.filter(function(l) {
                    return l.departmentId === $scope.filterByDepartment;
                });

                $scope.lecturers.forEach(function(lecturer) {
                    $scope.loadLecturerSubjectCount(lecturer);
                });
            })
            .catch(function(error) {
                console.error('Error loading lecturers:', error);
            });
    };

    $scope.loadLecturerSubjectCount = function(lecturer) {
        $http.get(API_CONFIG.BASE_URL + '/admin/lecturersubject/lecturer/' + lecturer.lecturerId)
            .then(function(response) {
                lecturer.subjectCount = (response.data.data || []).length;
            })
            .catch(function() {
                lecturer.subjectCount = 0;
            });
    };

    $scope.loadDepartments = function() {
        $http.get(API_CONFIG.BASE_URL + '/admin/department')
            .then(function(response) {
                $scope.departments = response.data;
            })
            .catch(function(error) {
                console.error('Error loading departments:', error);
            });
    };

    $scope.openLecturerModal = function() {
        $scope.lecturerForm = { isActive: true };
        $('#lecturerModal').modal('show');
    };

    $scope.editLecturer = function(lecturer) {
        $scope.lecturerForm = angular.copy(lecturer);
        $('#lecturerModal').modal('show');
    };

    $scope.saveLecturer = function() {
        if (!$scope.lecturerForm.fullName || !$scope.lecturerForm.email || 
            !$scope.lecturerForm.departmentId) {
            alert('Vui lòng điền đầy đủ thông tin bắt buộc!');
            return;
        }

        var method = $scope.lecturerForm.lecturerId ? 'PUT' : 'POST';
        var url = API_CONFIG.BASE_URL + '/lecturer';
        if (method === 'PUT') {
            url += '/' + $scope.lecturerForm.lecturerId;
        }

        $http({
            method: method,
            url: url,
            data: $scope.lecturerForm
        })
        .then(function(response) {
            alert('✅ Lưu thông tin Giảng viên thành công!');
            $('#lecturerModal').modal('hide');
            $scope.loadLecturers();
            $scope.lecturerForm = {};
        })
        .catch(function(error) {
            console.error('Error saving lecturer:', error);
            alert('❌ Lỗi: ' + (error.data?.message || 'Không thể lưu thông tin Giảng viên'));
        });
    };

    $scope.deleteLecturer = function(lecturerId) {
        if (!confirm('Bạn có chắc muốn xóa Giảng viên này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/lecturer/' + lecturerId)
            .then(function(response) {
                alert('🗑 Đã xóa Giảng viên!');
                $scope.loadLecturers();
            })
            .catch(function(error) {
                console.error('Error deleting lecturer:', error);
                alert('❌ Lỗi: ' + (error.data?.message || 'Không thể xóa Giảng viên'));
            });
    };

    // =========================
    // SUBJECT ASSIGNMENT FUNCTIONS
    // =========================
    $scope.loadAllSubjects = function() {
        $http.get(API_CONFIG.BASE_URL + '/subject')
            .then(function(response) {
                $scope.allSubjects = response.data;
                
                // Load assigned lecturers for each subject
                $scope.allSubjects.forEach(function(subject) {
                    $scope.loadSubjectLecturers(subject);
                });
            })
            .catch(function(error) {
                console.error('Error loading subjects:', error);
            });
    };

    $scope.loadSubjectLecturers = function(subject) {
        $http.get(API_CONFIG.BASE_URL + '/admin/lecturersubject/subject/' + subject.subjectId)
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
        $http.get(API_CONFIG.BASE_URL + '/admin/lecturersubject/lecturer/' + lecturer.lecturerId)
            .then(function(response) {
                $scope.lecturerSubjects = response.data.data || [];
                
                // Get available subjects (not yet assigned)
                var assignedSubjectIds = $scope.lecturerSubjects.map(function(ls) {
                    return ls.subjectId;
                });
                
                $scope.availableSubjects = $scope.allSubjects.filter(function(s) {
                    return assignedSubjectIds.indexOf(s.subjectId) === -1;
                });
                
                $('#assignSubjectsModal').modal('show');
            })
            .catch(function(error) {
                console.error('Error loading lecturer subjects:', error);
                alert('Lỗi khi tải danh sách môn học của giảng viên!');
            });
    };

    $scope.addSubjectToLecturer = function() {
        if (!$scope.newSubject.subjectId) {
            alert('Vui lòng chọn môn học!');
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

        $http.post(API_CONFIG.BASE_URL + '/admin/lecturersubject', data)
            .then(function(response) {
                alert('✅ Đã phân môn cho giảng viên!');
                $scope.assignSubjects($scope.selectedLecturer); // Reload
                $scope.newSubject = { isPrimary: false, experienceYears: 0 };
                $scope.loadLecturers(); // Update count
            })
            .catch(function(error) {
                console.error('Error assigning subject:', error);
                alert('❌ Lỗi: ' + (error.data?.message || 'Không thể phân môn'));
            });
    };

    $scope.removeSubject = function(lecturerSubjectId) {
        if (!confirm('Bạn có chắc muốn bỏ môn này?')) {
            return;
        }

        $http.delete(API_CONFIG.BASE_URL + '/admin/lecturersubject/' + lecturerSubjectId)
            .then(function(response) {
                alert('🗑 Đã bỏ môn học!');
                $scope.assignSubjects($scope.selectedLecturer); // Reload
                $scope.loadLecturers(); // Update count
            })
            .catch(function(error) {
                console.error('Error removing subject:', error);
                alert('❌ Lỗi: ' + (error.data?.message || 'Không thể bỏ môn'));
            });
    };

    $scope.viewLecturerSubjects = function(lecturer) {
        $scope.assignSubjects(lecturer);
    };

    // Initialize on load
    $scope.init();
}]);

