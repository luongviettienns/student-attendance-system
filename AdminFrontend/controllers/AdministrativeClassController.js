// Administrative Class Controller
app.controller('AdministrativeClassController', [
    '$scope', '$location', '$routeParams', '$timeout', 'AdministrativeClassService', 'MajorService', 
    'LecturerService', 'AcademicYearService', 'ToastService', 'AuthService',
    function($scope, $location, $routeParams, $timeout, AdministrativeClassService, MajorService, 
             LecturerService, AcademicYearService, ToastService, AuthService) {
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.classes = [];
    $scope.currentClass = null;
    $scope.majors = [];
    $scope.lecturers = [];
    $scope.academicYears = [];
    $scope.students = [];
    $scope.loading = false;
    
    $scope.filters = {
        search: '',
        majorId: '',
        cohortYear: null,
        advisorId: ''
    };
    
    $scope.pagination = {
        page: 1,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0
    };
    
    // Check authorization
    $scope.isAdmin = function() {
        const user = AuthService.getCurrentUser();
        return user && (user.roleName === 'Admin' || user.roleName === 'SuperAdmin' || user.role === 'Admin' || user.role === 'SuperAdmin');
    };
    
    // ============================================================
    // LOAD DATA
    // ============================================================
    $scope.loadClasses = function() {
        $scope.loading = true;
        
        return AdministrativeClassService.getAll(
            $scope.pagination.page,
            $scope.pagination.pageSize,
            $scope.filters.search,
            $scope.filters.majorId,
            $scope.filters.cohortYear,
            $scope.filters.advisorId
        ).then(function(response) {
            if (response.data && response.data.success) {
                var classesData = response.data.data || [];
                
                // Đảm bảo data là array
                if (!Array.isArray(classesData)) {
                    classesData = [];
                }
                
                // Update scope with new data - create completely new array with deep copy
                var newClasses = [];
                angular.forEach(classesData, function(item) {
                    newClasses.push(angular.copy(item)); // Deep copy to ensure new reference
                });
                
                // Assign new array to trigger change detection
                $scope.classes.length = 0; // Clear existing array
                Array.prototype.push.apply($scope.classes, newClasses); // Add new items
                $scope.pagination.totalCount = response.data.totalCount || 0;
                $scope.pagination.totalPages = response.data.totalPages || 0;
                $scope.loading = false;
                
                // Force Angular to detect changes - use $timeout to ensure digest cycle
                $timeout(function() {
                    if (!$scope.$$phase && !$scope.$root.$$phase) {
                        $scope.$apply();
                    }
                }, 0);
                
                return $scope.classes;
            } else {
                $scope.loading = false;
                return $scope.classes || [];
            }
        }).catch(function(error) {
            ToastService.error('Không thể tải danh sách lớp hành chính');
            $scope.loading = false;
            return [];
        });
    };
    
    $scope.loadMajors = function() {
        MajorService.getAll().then(function(response) {
            $scope.majors = response.data.data || response.data;
        });
    };
    
    $scope.loadLecturers = function() {
        LecturerService.getAll().then(function(response) {
            $scope.lecturers = response.data.data || response.data;
        });
    };
    
    $scope.loadAcademicYears = function() {
        AcademicYearService.getAll().then(function(response) {
            $scope.academicYears = response.data.data || response.data;
        });
    };
    
    // ============================================================
    // VIEW DETAIL
    // ============================================================
    $scope.viewDetail = function(classId) {
        $scope.loading = true;
        $scope.students = []; // Reset students list
        
        AdministrativeClassService.getById(classId).then(function(response) {
            if (response.data && response.data.success) {
                $scope.currentClass = response.data.data;
                
                // Load students using the helper function
                $scope.loadStudents(classId).then(function(students) {
                    console.log('Students loaded in viewDetail:', students.length);
                    $scope.loading = false;
                    
                    // Use ModalUtils to open modal
                    $timeout(function() {
                        if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                            window.ModalUtils.open('detailModal');
                        } else {
                            // Fallback: use class-based approach
                            $('#detailModal').addClass('active');
                            $('#modal-overlay').addClass('active');
                            $('body').css('overflow', 'hidden');
                        }
                    }, 100);
                }).catch(function(error) {
                    console.error('Error loading students:', error);
                    $scope.students = [];
                    $scope.loading = false;
                    ToastService.error('Không thể tải danh sách sinh viên');
                });
            } else {
                $scope.loading = false;
                ToastService.error('Không thể tải thông tin lớp hành chính');
            }
        }).catch(function(error) {
            console.error('Error loading class detail:', error);
            $scope.loading = false;
            ToastService.error('Không thể tải thông tin lớp hành chính');
        });
    };
    
    $scope.loadStudents = function(classId) {
        return AdministrativeClassService.getStudents(classId).then(function(response) {
            // Handle different response structures
            var studentsData = [];
            if (response && response.data) {
                if (response.data.success && response.data.data) {
                    studentsData = response.data.data;
                } else if (Array.isArray(response.data)) {
                    studentsData = response.data;
                } else if (response.data.data && Array.isArray(response.data.data)) {
                    studentsData = response.data.data;
                }
            }
            
            $scope.students = studentsData;
            console.log('Loaded students:', $scope.students.length, 'for class:', classId);
            return $scope.students;
        }).catch(function(error) {
            console.error('Error loading students:', error);
            $scope.students = [];
            return [];
        });
    };
    
    $scope.closeDetailModal = function() {
        if (window.ModalUtils && typeof window.ModalUtils.close === 'function') {
            window.ModalUtils.close('detailModal');
        } else if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
            window.ModalUtils.closeAll();
        } else {
            // Fallback: use class-based approach
            $('#detailModal').removeClass('active');
            $('#modal-overlay').removeClass('active');
            $('body').css('overflow', '');
        }
    };
    
    // ============================================================
    // CREATE / UPDATE
    // ============================================================
    $scope.showCreateModal = function() {
        $scope.currentClass = {
            classCode: '',
            className: '',
            majorId: '',
            advisorId: '',
            academicYearId: '',
            cohortYear: new Date().getFullYear(),
            maxStudents: 50,
            description: ''
        };
        
        $timeout(function() {
            if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                window.ModalUtils.open('classModal');
            } else {
                $('#classModal').addClass('active');
                $('#modal-overlay').addClass('active');
                $('body').css('overflow', 'hidden');
            }
        }, 100);
    };
    
    $scope.showEditModal = function(adminClass) {
        $scope.currentClass = angular.copy(adminClass);
        
        $timeout(function() {
            if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                window.ModalUtils.open('classModal');
            } else {
                $('#classModal').addClass('active');
                $('#modal-overlay').addClass('active');
                $('body').css('overflow', 'hidden');
            }
        }, 100);
    };
    
    $scope.closeClassModal = function() {
        if (window.ModalUtils && typeof window.ModalUtils.close === 'function') {
            window.ModalUtils.close('classModal');
        } else if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
            window.ModalUtils.closeAll();
        } else {
            $('#classModal').removeClass('active');
            $('#modal-overlay').removeClass('active');
            $('body').css('overflow', '');
        }
    };
    
    $scope.saveClass = function() {
        if (!$scope.currentClass) return;
        
        const isNew = !$scope.currentClass.adminClassId;
        const promise = isNew ? 
            AdministrativeClassService.create($scope.currentClass) :
            AdministrativeClassService.update($scope.currentClass.adminClassId, $scope.currentClass);
        
        promise.then(function(response) {
            if (response.data.success) {
                ToastService.success(isNew ? 'Tạo lớp hành chính thành công' : 'Cập nhật lớp hành chính thành công');
                $scope.closeClassModal();
                $scope.loadClasses();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Có lỗi xảy ra');
        });
    };
    
    // ============================================================
    // DELETE
    // ============================================================
    $scope.deleteClass = function(classId) {
        if (!confirm('Bạn có chắc chắn muốn xóa lớp hành chính này?')) return;
        
        AdministrativeClassService.delete(classId).then(function(response) {
            if (response.data.success) {
                ToastService.success('Xóa lớp hành chính thành công');
                $scope.loadClasses();
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Không thể xóa lớp hành chính');
        });
    };
    
    // ============================================================
    // ASSIGN STUDENTS
    // ============================================================
    $scope.showAssignModal = function(adminClass) {
        $scope.currentClass = adminClass;
        // TODO: Load available students
        
        $timeout(function() {
            if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                window.ModalUtils.open('assignModal');
            } else {
                $('#assignModal').addClass('active');
                $('#modal-overlay').addClass('active');
                $('body').css('overflow', 'hidden');
            }
        }, 100);
    };
    
    $scope.closeAssignModal = function() {
        if (window.ModalUtils && typeof window.ModalUtils.close === 'function') {
            window.ModalUtils.close('assignModal');
        } else if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
            window.ModalUtils.closeAll();
        } else {
            $('#assignModal').removeClass('active');
            $('#modal-overlay').removeClass('active');
            $('body').css('overflow', '');
        }
    };
    
    $scope.assignStudents = function(studentIds) {
        AdministrativeClassService.assignStudents($scope.currentClass.adminClassId, studentIds)
            .then(function(response) {
                if (response.data.success) {
                    ToastService.success('Phân bổ sinh viên thành công');
                    $scope.closeAssignModal();
                    $scope.loadStudents($scope.currentClass.adminClassId);
                }
            }).catch(function(error) {
                ToastService.error(error.data?.message || 'Có lỗi xảy ra');
            });
    };
    
    // ============================================================
    // REMOVE STUDENT
    // ============================================================
    $scope.removeStudent = function(studentId) {
        if (!confirm('Bạn có chắc chắn muốn xóa sinh viên khỏi lớp?')) return;
        
        AdministrativeClassService.removeStudent($scope.currentClass.adminClassId, studentId)
            .then(function(response) {
                if (response.data.success) {
                    ToastService.success('Xóa sinh viên khỏi lớp thành công');
                    $scope.loadStudents($scope.currentClass.adminClassId);
                }
            }).catch(function(error) {
                ToastService.error(error.data?.message || 'Có lỗi xảy ra');
            });
    };
    
    // ============================================================
    // TRANSFER STUDENT TO ANOTHER CLASS
    // ============================================================
    $scope.showTransferModal = function(student) {
        $scope.transferStudent = angular.copy(student);
        $scope.transferData = {
            studentId: student.studentId,
            toClassId: '',
            transferReason: ''
        };
        $scope.loadClasses(); // Load all classes for selection
        
        // Use ModalUtils or class-based approach
        $timeout(function() {
            if (window.ModalUtils && typeof window.ModalUtils.open === 'function') {
                window.ModalUtils.open('transferModal');
            } else {
                // Fallback: use class-based approach
                $('#transferModal').addClass('active');
                $('#modal-overlay').addClass('active');
                $('body').css('overflow', 'hidden');
            }
        }, 100);
    };
    
    $scope.closeTransferModal = function() {
        if (window.ModalUtils && typeof window.ModalUtils.close === 'function') {
            window.ModalUtils.close('transferModal');
        } else if (window.ModalUtils && typeof window.ModalUtils.closeAll === 'function') {
            window.ModalUtils.closeAll();
        } else {
            // Fallback: use class-based approach
            $('#transferModal').removeClass('active');
            $('#modal-overlay').removeClass('active');
            $('body').css('overflow', '');
        }
    };
    
    $scope.transferStudentClass = function() {
        if (!$scope.transferData.toClassId) {
            ToastService.error('Vui lòng chọn lớp đích');
            return;
        }
        
        if (!confirm('Bạn có chắc chắn muốn chuyển sinh viên sang lớp mới?')) return;
        
        var currentClassId = $scope.currentClass ? $scope.currentClass.adminClassId : null;
        var studentId = $scope.transferData.studentId;
        
        AdministrativeClassService.transferStudent(
            studentId,
            $scope.transferData.toClassId,
            $scope.transferData.transferReason
        ).then(function(response) {
            if (response.data.success) {
                ToastService.success('Chuyển lớp thành công');
                $scope.closeTransferModal();
                
                // Reload cả 2 đồng thời: danh sách lớp trên trang chính và modal chi tiết
                // 1. Reload danh sách lớp trên trang chính để cập nhật sĩ số
                $scope.loadClasses();
                
                // 2. Reload lại modal chi tiết lớp hiện tại nếu đang mở (chạy song song)
                if (currentClassId) {
                    $timeout(function() {
                        AdministrativeClassService.getById(currentClassId).then(function(classResponse) {
                            if (classResponse.data.success) {
                                $scope.currentClass = classResponse.data.data;
                                
                                // Reload lại danh sách sinh viên (sinh viên đã chuyển sẽ không còn trong danh sách)
                                $scope.loadStudents(currentClassId).then(function() {
                                    // Remove the transferred student from the list if still present
                                    $scope.students = $scope.students.filter(function(s) {
                                        return s.studentId !== studentId;
                                    });
                                });
                            }
                        }).catch(function(error) {
                            console.error('Error reloading class:', error);
                        });
                    }, 200);
                }
            }
        }).catch(function(error) {
            ToastService.error(error.data?.message || 'Có lỗi xảy ra khi chuyển lớp');
        });
    };
    
    // ============================================================
    // PAGINATION
    // ============================================================
    $scope.changePage = function(page) {
        $scope.pagination.page = page;
        $scope.loadClasses();
    };
    
    $scope.applyFilters = function() {
        $scope.pagination.page = 1;
        $scope.loadClasses();
    };
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    $scope.init = function() {
        $scope.loadClasses();
        $scope.loadMajors();
        $scope.loadLecturers();
        $scope.loadAcademicYears();
    };
    
    $scope.init();
}]);

