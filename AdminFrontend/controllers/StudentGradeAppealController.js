// @ts-check
/* global angular */
'use strict';

// Student Grade Appeal Controller
app.controller('StudentGradeAppealController', [
    '$scope',
    '$routeParams',
    'AuthService',
    'GradeAppealService',
    'GradeService',
    'ClassService',
    'ToastService',
    'LoggerService',
    function($scope, $routeParams, AuthService, GradeAppealService, GradeService, ClassService, ToastService, LoggerService) {
        $scope.currentUser = AuthService.getCurrentUser();
        $scope.studentId = null;
        
        // Appeals list
        $scope.appeals = [];
        $scope.loading = false;
        $scope.error = null;
        $scope.filters = {
            status: null,
            priority: null
        };
        
        // Pagination
        $scope.pagination = {
            page: 1,
            pageSize: 10,
            totalCount: 0
        };
        
        // Create appeal modal
        $scope.showCreateModal = false;
        $scope.newAppeal = {
            gradeId: null,
            enrollmentId: null,
            classId: null,
            appealReason: '',
            currentScore: null,
            expectedScore: null,
            supportingDocs: null,
            priority: 'NORMAL'
        };
        $scope.availableGrades = [];
        $scope.loadingGrades = false;
        $scope.saving = false;
        
        // Appeal detail
        $scope.selectedAppeal = null;
        $scope.showDetailModal = false;
        
        // Load student ID
        function loadStudentId() {
            if (!$scope.currentUser || !$scope.currentUser.userId) {
                $scope.error = 'Không tìm thấy thông tin người dùng.';
                return;
            }
            
            // Get student by user ID (you may need to adjust this based on your StudentService)
            // For now, assuming studentId is available from route or currentUser
            $scope.studentId = $routeParams.studentId || $scope.currentUser.studentId;
            
            if ($scope.studentId) {
                loadAppeals();
                loadAvailableGrades();
            } else {
                $scope.error = 'Không tìm thấy mã sinh viên.';
            }
        }
        
        // Load appeals
        function loadAppeals() {
            $scope.loading = true;
            $scope.error = null;
            
            var filters = {
                studentId: $scope.studentId
            };
            if ($scope.filters.status) filters.status = $scope.filters.status;
            if ($scope.filters.priority) filters.priority = $scope.filters.priority;
            
            GradeAppealService.getAll(filters, $scope.pagination.page, $scope.pagination.pageSize)
                .then(function(result) {
                    $scope.appeals = result.appeals || [];
                    $scope.pagination.totalCount = result.totalCount || 0;
                    $scope.loading = false;
                })
                .catch(function(error) {
                    $scope.error = 'Không thể tải danh sách phúc khảo: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                    $scope.loading = false;
                    LoggerService.error('Error loading appeals', error);
                });
        }
        
        // Load available grades for creating appeal
        function loadAvailableGrades() {
            if (!$scope.studentId) return;
            
            $scope.loadingGrades = true;
            // Get all grades for student (without school year filter to show all available)
            // You may need to adjust this based on your actual GradeService API
            GradeService.getByStudentSchoolYear($scope.studentId, null, null, { forceRefresh: false })
                .then(function(grades) {
                    $scope.availableGrades = (grades || []).filter(function(g) {
                        return g.totalScore !== null && g.totalScore !== undefined;
                    });
                    $scope.loadingGrades = false;
                })
                .catch(function(error) {
                    LoggerService.error('Error loading grades', error);
                    $scope.loadingGrades = false;
                    $scope.availableGrades = [];
                });
        }
        
        // Open create modal
        $scope.openCreateModal = function() {
            $scope.newAppeal = {
                gradeId: null,
                enrollmentId: null,
                classId: null,
                appealReason: '',
                currentScore: null,
                expectedScore: null,
                supportingDocs: null,
                priority: 'NORMAL'
            };
            $scope.showCreateModal = true;
        };
        
        // Close create modal
        $scope.closeCreateModal = function() {
            $scope.showCreateModal = false;
        };
        
        // Select grade for appeal
        $scope.selectGrade = function(grade) {
            $scope.newAppeal.gradeId = grade.gradeId;
            $scope.newAppeal.enrollmentId = grade.enrollmentId;
            $scope.newAppeal.classId = grade.classId;
            $scope.newAppeal.currentScore = grade.totalScore;
        };
        
        // Create appeal
        $scope.createAppeal = function() {
            if (!$scope.newAppeal.gradeId) {
                ToastService.error('Vui lòng chọn điểm cần phúc khảo');
                return;
            }
            
            if (!$scope.newAppeal.appealReason || $scope.newAppeal.appealReason.trim().length < 10) {
                ToastService.error('Vui lòng nhập lý do phúc khảo (ít nhất 10 ký tự)');
                return;
            }
            
            $scope.saving = true;
            
            var appealData = {
                gradeId: $scope.newAppeal.gradeId,
                enrollmentId: $scope.newAppeal.enrollmentId,
                studentId: $scope.studentId,
                classId: $scope.newAppeal.classId,
                appealReason: $scope.newAppeal.appealReason,
                currentScore: $scope.newAppeal.currentScore,
                expectedScore: $scope.newAppeal.expectedScore,
                supportingDocs: $scope.newAppeal.supportingDocs,
                priority: $scope.newAppeal.priority,
                createdBy: $scope.currentUser.userId || $scope.studentId
            };
            
            GradeAppealService.create(appealData)
                .then(function(response) {
                    ToastService.success('Tạo yêu cầu phúc khảo thành công!');
                    $scope.closeCreateModal();
                    loadAppeals();
                })
                .catch(function(error) {
                    ToastService.error('Lỗi: ' + (error.data?.message || error.message || 'Không thể tạo yêu cầu phúc khảo'));
                    LoggerService.error('Error creating appeal', error);
                })
                .finally(function() {
                    $scope.saving = false;
                });
        };
        
        // View appeal detail
        $scope.viewDetail = function(appealId) {
            $scope.loading = true;
            GradeAppealService.getById(appealId)
                .then(function(appeal) {
                    $scope.selectedAppeal = appeal;
                    $scope.showDetailModal = true;
                    $scope.loading = false;
                })
                .catch(function(error) {
                    ToastService.error('Không thể tải chi tiết phúc khảo');
                    LoggerService.error('Error loading appeal detail', error);
                    $scope.loading = false;
                });
        };
        
        // Close detail modal
        $scope.closeDetailModal = function() {
            $scope.showDetailModal = false;
            $scope.selectedAppeal = null;
        };
        
        // Cancel appeal
        $scope.cancelAppeal = function(appealId) {
            if (!confirm('Bạn có chắc chắn muốn hủy yêu cầu phúc khảo này?')) {
                return;
            }
            
            GradeAppealService.cancel(appealId, $scope.currentUser.userId || $scope.studentId)
                .then(function() {
                    ToastService.success('Hủy yêu cầu phúc khảo thành công');
                    loadAppeals();
                })
                .catch(function(error) {
                    ToastService.error('Lỗi: ' + (error.data?.message || error.message || 'Không thể hủy yêu cầu'));
                    LoggerService.error('Error cancelling appeal', error);
                });
        };
        
        // Get status badge class
        $scope.getStatusBadgeClass = function(status) {
            var classes = {
                'PENDING': 'badge-warning',
                'REVIEWING': 'badge-info',
                'APPROVED': 'badge-success',
                'REJECTED': 'badge-danger',
                'CANCELLED': 'badge-secondary'
            };
            return classes[status] || 'badge-secondary';
        };
        
        // Get priority badge class
        $scope.getPriorityBadgeClass = function(priority) {
            var classes = {
                'LOW': 'badge-secondary',
                'NORMAL': 'badge-primary',
                'HIGH': 'badge-warning',
                'URGENT': 'badge-danger'
            };
            return classes[priority] || 'badge-secondary';
        };
        
        // Filter appeals
        $scope.applyFilters = function() {
            $scope.pagination.page = 1;
            loadAppeals();
        };
        
        // Clear filters
        $scope.clearFilters = function() {
            $scope.filters = {
                status: null,
                priority: null
            };
            $scope.applyFilters();
        };
        
        // Pagination
        $scope.handlePageChange = function() {
            loadAppeals();
        };
        
        // Initialize
        loadStudentId();
    }
]);

