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
        AuthService.logout();
        window.location.href = '#!/login';
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
        AuditLogService.getAll()
            .then(function(response) {
                $scope.logs = response.data;
                $scope.applyFiltersAndSort();
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải audit log';
                $scope.loading = false;
            });
    };
    
    // Apply filters and sorting
    $scope.applyFiltersAndSort = function() {
        var filtered = $scope.logs;
        
        // Apply search
        if ($scope.pagination.searchTerm) {
            var searchLower = $scope.pagination.searchTerm.toLowerCase();
            filtered = filtered.filter(function(log) {
                return (log.userName && log.userName.toLowerCase().includes(searchLower)) ||
                       (log.action && log.action.toLowerCase().includes(searchLower)) ||
                       (log.entityType && log.entityType.toLowerCase().includes(searchLower)) ||
                       (log.entityName && log.entityName.toLowerCase().includes(searchLower)) ||
                       (log.details && log.details.toLowerCase().includes(searchLower));
            });
        }
        
        // Apply filters
        if ($scope.filters.userId) {
            filtered = filtered.filter(function(log) {
                return log.userId == $scope.filters.userId;
            });
        }
        
        if ($scope.filters.action) {
            filtered = filtered.filter(function(log) {
                return log.action === $scope.filters.action;
            });
        }
        
        if ($scope.filters.entityType) {
            filtered = filtered.filter(function(log) {
                return log.entityType === $scope.filters.entityType;
            });
        }
        
        if ($scope.filters.dateFrom) {
            var dateFrom = new Date($scope.filters.dateFrom);
            filtered = filtered.filter(function(log) {
                return new Date(log.createdAt) >= dateFrom;
            });
        }
        
        if ($scope.filters.dateTo) {
            var dateTo = new Date($scope.filters.dateTo);
            dateTo.setHours(23, 59, 59, 999);
            filtered = filtered.filter(function(log) {
                return new Date(log.createdAt) <= dateTo;
            });
        }
        
        // Apply sorting (default by createdAt DESC)
        if (!$scope.pagination.sortField) {
            $scope.pagination.sortField = 'createdAt';
            $scope.pagination.sortDirection = 'desc';
        }
        
        filtered.sort(function(a, b) {
            var aVal = a[$scope.pagination.sortField] || '';
            var bVal = b[$scope.pagination.sortField] || '';
            
            if (aVal < bVal) return $scope.pagination.sortDirection === 'asc' ? -1 : 1;
            if (aVal > bVal) return $scope.pagination.sortDirection === 'asc' ? 1 : -1;
            return 0;
        });
        
        // Update pagination
        $scope.pagination.totalItems = filtered.length;
        $scope.pagination = PaginationService.calculate($scope.pagination);
        
        // Apply pagination
        var start = ($scope.pagination.currentPage - 1) * $scope.pagination.pageSize;
        var end = start + parseInt($scope.pagination.pageSize);
        $scope.displayedLogs = filtered.slice(start, end);
    };
    
    // Event handlers
    $scope.handleSearch = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    $scope.handleSort = function() {
        $scope.applyFiltersAndSort();
    };
    
    $scope.handlePageChange = function() {
        $scope.applyFiltersAndSort();
    };
    
    $scope.handleFilterChange = function() {
        $scope.pagination.currentPage = 1;
        $scope.applyFiltersAndSort();
    };
    
    $scope.resetFilters = function() {
        $scope.pagination.searchTerm = '';
        $scope.filters = {
            userId: '',
            action: '',
            entityType: '',
            dateFrom: '',
            dateTo: ''
        };
        $scope.handleFilterChange();
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
    
    // Initialize
    $scope.loadLogs();
}]);

