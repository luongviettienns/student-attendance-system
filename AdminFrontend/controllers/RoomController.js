// Room Management Controller
app.controller('RoomController', ['$scope', '$timeout', 'RoomService', 'ToastService', 'LoggerService', 'RoleService',
    function($scope, $timeout, RoomService, ToastService, LoggerService, RoleService) {
    
    $scope.rooms = [];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    
    // ✅ THÊM: Permission checks
    $scope.canManageRooms = false;
    $scope.canCreateRooms = false;
    $scope.canEditRooms = false;
    $scope.canDeleteRooms = false;
    
    // Pagination
    $scope.pagination = {
        currentPage: 1,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0
    };
    
    // Filters
    $scope.filters = {
        search: '',
        isActive: null // null = all, true = active, false = inactive
    };
    
    // Form data
    $scope.roomForm = {};
    $scope.formMode = 'create'; // 'create' or 'edit'
    $scope.showModal = false;
    
    // Load rooms with pagination
    $scope.loadRooms = function() {
        $scope.loading = true;
        $scope.error = null;
        
        RoomService.getAll(
            $scope.pagination.currentPage,
            $scope.pagination.pageSize,
            $scope.filters.search || null,
            $scope.filters.isActive
        )
        .then(function(response) {
            var result = response.data;
            if (result && result.success) {
                $scope.rooms = result.data || [];
                $scope.pagination.totalCount = result.totalCount || 0;
                $scope.pagination.totalPages = result.totalPages || 0;
            } else {
                $scope.rooms = result.data || result || [];
            }
            $scope.loading = false;
        })
        .catch(function(error) {
            $scope.error = 'Không thể tải danh sách phòng học: ' + (error.data?.message || error.message || 'Lỗi không xác định');
            $scope.loading = false;
            LoggerService.error('Load rooms error', error);
        });
    };
    
    // Search rooms
    $scope.searchRooms = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadRooms();
    };
    
    // Open create modal
    $scope.openCreateModal = function() {
        $scope.roomForm = {
            roomCode: '',
            building: '',
            capacity: null,
            isActive: true
        };
        $scope.formMode = 'create';
        $scope.showModal = true;
        $scope.error = null;
    };
    
    // Open edit modal
    $scope.openEditModal = function(room) {
        $scope.roomForm = {
            roomId: room.roomId,
            roomCode: room.roomCode,
            building: room.building || '',
            capacity: room.capacity,
            isActive: room.isActive !== undefined ? room.isActive : true
        };
        $scope.formMode = 'edit';
        $scope.showModal = true;
        $scope.error = null;
    };
    
    // Close modal
    $scope.closeModal = function() {
        $scope.showModal = false;
        $scope.roomForm = {};
        $scope.error = null;
    };
    
    // Save room (create or update)
    $scope.saveRoom = function() {
        // Validation
        if (!$scope.roomForm.roomCode || $scope.roomForm.roomCode.trim() === '') {
            $scope.error = 'Mã phòng học không được để trống';
            return;
        }
        
        if ($scope.roomForm.capacity !== null && $scope.roomForm.capacity !== undefined) {
            if (isNaN($scope.roomForm.capacity) || $scope.roomForm.capacity <= 0) {
                $scope.error = 'Sức chứa phòng học phải là số lớn hơn 0';
                return;
            }
        }
        
        $scope.loading = true;
        $scope.error = null;
        
        var savePromise;
        if ($scope.formMode === 'create') {
            savePromise = RoomService.create($scope.roomForm);
        } else {
            savePromise = RoomService.update($scope.roomForm.roomId, $scope.roomForm);
        }
        
        savePromise
            .then(function(response) {
                var result = response.data;
                if (result && result.success) {
                    ToastService.success(result.message || 'Lưu phòng học thành công');
                    $scope.closeModal();
                    $scope.loadRooms();
                } else {
                    $scope.error = result?.message || 'Lưu phòng học thất bại';
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || error.data?.error || 'Không thể lưu phòng học';
                $scope.loading = false;
                LoggerService.error('Save room error', error);
            });
    };
    
    // Delete room
    $scope.deleteRoom = function(room) {
        if (!confirm('Bạn có chắc chắn muốn xóa phòng học "' + room.roomCode + '"?')) {
            return;
        }
        
        $scope.loading = true;
        RoomService.delete(room.roomId)
            .then(function(response) {
                var result = response.data;
                if (result && result.success) {
                    ToastService.success(result.message || 'Xóa phòng học thành công');
                    $scope.loadRooms();
                } else {
                    ToastService.error(result?.message || 'Xóa phòng học thất bại');
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || error.data?.error || 'Không thể xóa phòng học';
                ToastService.error(errorMsg);
                $scope.loading = false;
                LoggerService.error('Delete room error', error);
            });
    };
    
    // Toggle active
    $scope.toggleActive = function(room) {
        var updatedRoom = {
            roomId: room.roomId,
            roomCode: room.roomCode,
            building: room.building,
            capacity: room.capacity,
            isActive: !room.isActive
        };
        
        $scope.loading = true;
        RoomService.update(room.roomId, updatedRoom)
            .then(function(response) {
                var result = response.data;
                if (result && result.success) {
                    ToastService.success('Cập nhật trạng thái thành công');
                    $scope.loadRooms();
                } else {
                    ToastService.error('Cập nhật trạng thái thất bại');
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                ToastService.error('Không thể cập nhật trạng thái');
                $scope.loading = false;
                LoggerService.error('Toggle active error', error);
            });
    };
    
    // Pagination helpers
    $scope.goToPage = function(page) {
        if (page >= 1 && page <= $scope.pagination.totalPages) {
            $scope.pagination.currentPage = page;
            $scope.loadRooms();
        }
    };
    
    $scope.prevPage = function() {
        if ($scope.pagination.currentPage > 1) {
            $scope.pagination.currentPage--;
            $scope.loadRooms();
        }
    };
    
    $scope.nextPage = function() {
        if ($scope.pagination.currentPage < $scope.pagination.totalPages) {
            $scope.pagination.currentPage++;
            $scope.loadRooms();
        }
    };
    
    // Change page size
    $scope.changePageSize = function() {
        $scope.pagination.currentPage = 1;
        $scope.loadRooms();
    };
    
    // ✅ THÊM: Load permissions
    $scope.init = function() {
        RoleService.loadPermissions().then(function() {
            $scope.canManageRooms = RoleService.hasPermission('canManageRooms');
            $scope.canCreateRooms = RoleService.hasPermission('canManageRooms'); // Same permission
            $scope.canEditRooms = RoleService.hasPermission('canManageRooms');
            $scope.canDeleteRooms = RoleService.hasPermission('canManageRooms');
            
            LoggerService.debug('Room permissions loaded', {
                canManageRooms: $scope.canManageRooms
            });
            
            // Load data if has permission
            if ($scope.canManageRooms) {
                $scope.loadRooms();
            } else {
                $scope.error = 'Bạn không có quyền truy cập trang này';
            }
        }).catch(function(error) {
            LoggerService.error('Error loading room permissions', error);
            // Use fallback permissions
            $scope.canManageRooms = RoleService.hasPermission('canManageRooms');
            $scope.canCreateRooms = $scope.canManageRooms;
            $scope.canEditRooms = $scope.canManageRooms;
            $scope.canDeleteRooms = $scope.canManageRooms;
            
            if ($scope.canManageRooms) {
                $scope.loadRooms();
            } else {
                $scope.error = 'Bạn không có quyền truy cập trang này';
            }
        });
    };
    
    // Initialize
    $scope.init();
}]);

