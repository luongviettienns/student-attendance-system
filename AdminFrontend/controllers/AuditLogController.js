// Audit Log Controller
app.controller('AuditLogController', ['$scope', '$location', 'AuditLogService', 'PaginationService', 'ExportService', 'AuthService', 'AvatarService',
    function($scope, $location, AuditLogService, PaginationService, ExportService, AuthService, AvatarService) {
    
    $scope.logs = [];
    $scope.displayedLogs = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    
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
    
    // Pagination
    $scope.pagination = PaginationService.init(25);
    
    // Filters
    $scope.filters = {
        userId: '',
        action: '',
        entityType: '',
        dateFrom: '',
        dateTo: ''
    };
    
    // Action types
    $scope.actionTypes = [
        { value: 'CREATE', label: 'Thêm mới' },
        { value: 'UPDATE', label: 'Cập nhật' },
        { value: 'DELETE', label: 'Xóa' },
        { value: 'LOGIN', label: 'Đăng nhập' },
        { value: 'LOGOUT', label: 'Đăng xuất' },
        { value: 'EXPORT', label: 'Xuất dữ liệu' },
        { value: 'IMPORT', label: 'Nhập dữ liệu' }
    ];
    
    // Entity types
    $scope.entityTypes = [
        { value: 'User', label: 'Người dùng' },
        { value: 'Student', label: 'Sinh viên' },
        { value: 'Lecturer', label: 'Giảng viên' },
        { value: 'Faculty', label: 'Khoa' },
        { value: 'Major', label: 'Ngành' },
        { value: 'Subject', label: 'Môn học' },
        { value: 'Grade', label: 'Điểm' },
        { value: 'Attendance', label: 'Điểm danh' }
    ];
    
    // Load audit logs
    $scope.loadLogs = function() {
        $scope.loading = true;
        
        var params = {
            page: $scope.pagination.currentPage,
            pageSize: $scope.pagination.pageSize,
            search: $scope.pagination.searchTerm || null,
            action: $scope.filters.action || null,
            entityType: $scope.filters.entityType || null,
            userId: $scope.filters.userId || null,
            fromDate: $scope.filters.dateFrom || null,
            toDate: $scope.filters.dateTo || null
        };
        
        AuditLogService.getAll(params)
            .then(function(response) {
                if (response.data && response.data.data) {
                    $scope.logs = response.data.data.map(function(log) {
                        return {
                            logId: log.logId,
                            userId: log.userId,
                            userName: log.userFullName || log.userName || 'System',
                            action: log.action,
                            entityType: log.entityType,
                            entityId: log.entityId,
                            entityName: log.entityId, // You can enhance this later
                            details: log.newValues || log.oldValues || '',
                            ipAddress: log.ipAddress,
                            userAgent: log.userAgent,
                            createdAt: log.createdAt
                        };
                    });
                    
                    // Update pagination from server response
                    if (response.data.pagination) {
                        $scope.pagination.totalItems = response.data.pagination.totalCount;
                        $scope.pagination = PaginationService.calculate($scope.pagination);
                    }
                    
                    $scope.displayedLogs = $scope.logs;
                } else {
                    $scope.logs = [];
                    $scope.displayedLogs = [];
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                console.error('Error loading audit logs:', error);
                $scope.error = 'Không thể tải audit log: ' + (error.data?.message || error.message || 'Lỗi không xác định');
                $scope.loading = false;
            });
    };
    
    // Apply filters and sorting (now handled server-side)
    $scope.applyFiltersAndSort = function() {
        // Server-side filtering, just reload
        $scope.loadLogs();
    };
    
    // Event handlers
    $scope.handleSearch = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadLogs();
    };
    
    $scope.handleSort = function() {
        $scope.loadLogs();
    };
    
    $scope.handlePageChange = function() {
        $scope.loadLogs();
    };
    
    $scope.handleFilterChange = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadLogs();
    };
    
    $scope.resetFilters = function() {
        $scope.pagination.searchTerm = '';
        $scope.pagination.currentPage = 1;
        $scope.filters = {
            userId: '',
            action: '',
            entityType: '',
            dateFrom: '',
            dateTo: ''
        };
        $scope.loadLogs();
    };
    
    // Export to Excel
    $scope.exportToExcel = function() {
        var columns = [
            { label: 'Thời gian', field: 'createdAt' },
            { label: 'Người dùng', field: 'userName' },
            { label: 'Hành động', field: 'action' },
            { label: 'Đối tượng', field: 'entityType' },
            { label: 'Tên đối tượng', field: 'entityName' },
            { label: 'Chi tiết', field: 'details' },
            { label: 'IP Address', field: 'ipAddress' }
        ];
        
        ExportService.exportToExcel($scope.logs, 'AuditLog_' + new Date().toISOString().split('T')[0], columns);
    };
    
    // Get action badge class
    $scope.getActionClass = function(action) {
        var classes = {
            'CREATE': 'badge-success',
            'UPDATE': 'badge-info',
            'DELETE': 'badge-danger',
            'LOGIN': 'badge-primary',
            'LOGOUT': 'badge-secondary',
            'EXPORT': 'badge-warning',
            'IMPORT': 'badge-warning'
        };
        return classes[action] || 'badge-secondary';
    };
    
    // Format date
    $scope.formatDate = function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        return date.toLocaleString('vi-VN');
    };
    
    // View mode
    $scope.viewMode = 'timeline'; // 'timeline' or 'table'
    $scope.showFilters = false;
    $scope.showDetailsModal = false;
    $scope.selectedLog = {};
    
    // Toggle view mode
    $scope.toggleViewMode = function() {
        $scope.viewMode = $scope.viewMode === 'timeline' ? 'table' : 'timeline';
    };
    
    // Clear search
    $scope.clearSearch = function() {
        $scope.pagination.searchTerm = '';
        $scope.handleSearch();
    };
    
    // Check if has active filters
    $scope.hasActiveFilters = function() {
        return $scope.filters.action || 
               $scope.filters.entityType || 
               $scope.filters.dateFrom || 
               $scope.filters.dateTo;
    };
    
    // Get active filters count
    $scope.getActiveFiltersCount = function() {
        var count = 0;
        if ($scope.filters.action) count++;
        if ($scope.filters.entityType) count++;
        if ($scope.filters.dateFrom) count++;
        if ($scope.filters.dateTo) count++;
        return count;
    };
    
    // Apply filters
    $scope.applyFilters = function() {
        $scope.showFilters = false;
        $scope.handleFilterChange();
    };
    
    // Get action count for statistics
    $scope.getActionCount = function(action) {
        if (!$scope.logs || $scope.logs.length === 0) return 0;
        return $scope.logs.filter(function(log) {
            return log.action === action;
        }).length;
    };
    
    // Get action icon
    $scope.getActionIcon = function(action) {
        var icons = {
            'CREATE': 'fa-plus-circle',
            'UPDATE': 'fa-edit',
            'DELETE': 'fa-trash-alt',
            'LOGIN': 'fa-sign-in-alt',
            'LOGOUT': 'fa-sign-out-alt',
            'EXPORT': 'fa-file-download',
            'IMPORT': 'fa-file-upload'
        };
        return icons[action] || 'fa-circle';
    };
    
    // Get action label
    $scope.getActionLabel = function(action) {
        var labels = {
            'CREATE': 'Thêm mới',
            'UPDATE': 'Cập nhật',
            'DELETE': 'Xóa',
            'LOGIN': 'Đăng nhập',
            'LOGOUT': 'Đăng xuất',
            'EXPORT': 'Xuất dữ liệu',
            'IMPORT': 'Nhập dữ liệu'
        };
        return labels[action] || action;
    };
    
    // Get entity label
    $scope.getEntityLabel = function(entityType) {
        var labels = {
            'User': 'Người dùng',
            'Student': 'Sinh viên',
            'Lecturer': 'Giảng viên',
            'Faculty': 'Khoa',
            'Department': 'Bộ môn',
            'Major': 'Ngành',
            'Subject': 'Môn học',
            'Grade': 'Điểm',
            'Attendance': 'Điểm danh',
            'AcademicYear': 'Niên khóa',
            'Class': 'Lớp học',
            'users': 'Người dùng',
            'students': 'Sinh viên',
            'lecturers': 'Giảng viên',
            'faculties': 'Khoa',
            'departments': 'Bộ môn',
            'majors': 'Ngành',
            'subjects': 'Môn học',
            'grades': 'Điểm',
            'attendances': 'Điểm danh',
            'academic_years': 'Niên khóa',
            'classes': 'Lớp học'
        };
        return labels[entityType] || entityType;
    };
    
    // Get user agent info (simplified)
    $scope.getUserAgentInfo = function(userAgent) {
        if (!userAgent) return 'Unknown';
        
        // Detect browser
        if (userAgent.includes('Chrome')) return 'Chrome';
        if (userAgent.includes('Firefox')) return 'Firefox';
        if (userAgent.includes('Safari')) return 'Safari';
        if (userAgent.includes('Edge')) return 'Edge';
        if (userAgent.includes('MSIE') || userAgent.includes('Trident')) return 'IE';
        
        return 'Browser';
    };
    
    // View details modal
    $scope.viewDetails = function(log) {
        $scope.selectedLog = angular.copy(log);
        $scope.showDetailsModal = true;
    };
    
    // Close details modal
    $scope.closeDetailsModal = function() {
        $scope.showDetailsModal = false;
        $scope.selectedLog = {};
    };
    
    // Refresh logs
    $scope.refreshLogs = function() {
        $scope.loadLogs();
    };
    
    // Initialize
    $scope.loadLogs();
}]);

