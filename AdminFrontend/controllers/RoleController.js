// Role Controller
app.controller('RoleController', [
    '$scope', 
    'RoleManagementService', 
    'AuthService', 
    'AvatarService', 
    'ToastService',
    function($scope, RoleManagementService, AuthService, AvatarService, ToastService) {
    
    $scope.roles = [];
    $scope.permissions = [];
    $scope.loading = false;
    $scope.error = null;
    
    // Form data
    $scope.currentRole = null;
    $scope.isEditMode = false;
    $scope.roleForm = {
        roleName: '',
        description: '',
        isActive: true
    };
    
    // Permission management
    $scope.permissionManagement = {
        roleId: null,
        roleName: '',
        permissions: [],
        selectedPermissions: []
    };
    
    // Initialize Avatar Modal Functions
    AvatarService.initAvatarModal($scope);
    
    // Get current user for header
    $scope.getCurrentUser = function() {
        return AuthService.getCurrentUser();
    };
    
    // Logout function
    $scope.logout = function() {
        AuthService.logout();
    };
    
    // ============================================================
    // 🔹 LOAD DATA
    // ============================================================
    
    /**
     * Load all roles
     */
    $scope.loadRoles = function() {
        $scope.loading = true;
        $scope.error = null;
        
        RoleManagementService.getAllRoles()
            .then(function(response) {
                $scope.roles = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách vai trò';
                ToastService.error('Không thể tải danh sách vai trò');
                $scope.loading = false;
            });
    };
    
    /**
     * Load all permissions
     */
    $scope.loadPermissions = function() {
        RoleManagementService.getAllPermissions()
            .then(function(response) {
                $scope.permissions = response.data;
            })
            .catch(function(error) {
                ToastService.error('Không thể tải danh sách quyền');
            });
    };
    
    // ============================================================
    // 🔹 ROLE CRUD OPERATIONS
    // ============================================================
    
    /**
     * Open modal to create new role
     */
    $scope.openCreateModal = function() {
        $scope.isEditMode = false;
        $scope.currentRole = null;
        $scope.roleForm = {
            roleName: '',
            description: '',
            isActive: true
        };
        openModal('roleFormModal');
    };
    
    /**
     * Open modal to edit role
     */
    $scope.openEditModal = function(role) {
        $scope.isEditMode = true;
        $scope.currentRole = role;
        $scope.roleForm = {
            roleName: role.roleName,
            description: role.description,
            isActive: role.isActive
        };
        openModal('roleFormModal');
    };
    
    /**
     * Save role (create or update)
     */
    $scope.saveRole = function() {
        if (!$scope.roleForm.roleName) {
            ToastService.warning('Vui lòng nhập tên vai trò');
            return;
        }
        
        var roleData = {
            roleName: $scope.roleForm.roleName,
            description: $scope.roleForm.description,
            isActive: $scope.roleForm.isActive
        };
        
        var promise;
        if ($scope.isEditMode) {
            promise = RoleManagementService.updateRole($scope.currentRole.roleId, roleData);
        } else {
            promise = RoleManagementService.createRole(roleData);
        }
        
        promise
            .then(function(response) {
                ToastService.success(response.data.message || ($scope.isEditMode ? 'Cập nhật vai trò thành công' : 'Tạo vai trò thành công'));
                closeModal('roleFormModal');
                $scope.loadRoles();
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Có lỗi xảy ra';
                ToastService.error(errorMsg);
            });
    };
    
    /**
     * Delete role
     */
    $scope.deleteRole = function(role) {
        if (!confirm('Bạn có chắc chắn muốn xóa vai trò "' + role.roleName + '"?')) {
            return;
        }
        
        RoleManagementService.deleteRole(role.roleId)
            .then(function(response) {
                ToastService.success(response.data.message || 'Xóa vai trò thành công');
                $scope.loadRoles();
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Không thể xóa vai trò';
                ToastService.error(errorMsg);
            });
    };
    
    /**
     * Toggle role status
     */
    $scope.toggleStatus = function(role) {
        RoleManagementService.toggleRoleStatus(role.roleId)
            .then(function(response) {
                role.isActive = response.data.isActive;
                ToastService.success(response.data.message);
            })
            .catch(function(error) {
                ToastService.error('Không thể thay đổi trạng thái');
            });
    };
    
    // ============================================================
    // 🔹 PERMISSION MANAGEMENT
    // ============================================================
    
    /**
     * Open permission management modal
     */
    $scope.openPermissionModal = function(role) {
        $scope.permissionManagement.roleId = role.roleId;
        $scope.permissionManagement.roleName = role.roleName;
        $scope.permissionManagement.permissions = [];
        $scope.permissionManagement.selectedPermissions = [];
        
        // Load permissions for this role
        RoleManagementService.getPermissionsByRole(role.roleId)
            .then(function(response) {
                $scope.permissionManagement.permissions = response.data.permissions || response.data.Permissions || [];
                
                // Extract selected permission IDs
                $scope.permissionManagement.selectedPermissions = $scope.permissionManagement.permissions
                    .filter(function(p) { return p.isAssigned || p.IsAssigned; })
                    .map(function(p) { return p.permissionId || p.PermissionId; });
                    
                openModal('permissionModal');
            })
            .catch(function(error) {
                ToastService.error('Không thể tải danh sách quyền');
            });
    };
    
    /**
     * Toggle permission selection
     */
    $scope.togglePermission = function(permissionId) {
        var index = $scope.permissionManagement.selectedPermissions.indexOf(permissionId);
        if (index > -1) {
            $scope.permissionManagement.selectedPermissions.splice(index, 1);
        } else {
            $scope.permissionManagement.selectedPermissions.push(permissionId);
        }
    };
    
    /**
     * Check if permission is selected
     */
    $scope.isPermissionSelected = function(permissionId) {
        return $scope.permissionManagement.selectedPermissions.indexOf(permissionId) > -1;
    };
    
    /**
     * Save permissions for role
     */
    $scope.savePermissions = function() {
        RoleManagementService.assignPermissions(
            $scope.permissionManagement.roleId,
            $scope.permissionManagement.selectedPermissions
        )
            .then(function(response) {
                ToastService.success(response.data.message || 'Cập nhật quyền thành công');
                closeModal('permissionModal');
                $scope.loadRoles();
            })
            .catch(function(error) {
                var errorMsg = error.data?.message || 'Không thể cập nhật quyền';
                ToastService.error(errorMsg);
            });
    };
    
    // ============================================================
    // 🔹 MODAL HELPERS
    // ============================================================
    
    function openModal(modalId) {
        var modal = document.getElementById(modalId);
        if (modal) {
            // Use 'active' class to display modal per CSS rules
            modal.classList.add('active');
            // Prevent body scroll
            document.body.style.overflow = 'hidden';
        }
    }
    
    function closeModal(modalId) {
        var modal = document.getElementById(modalId);
        if (modal) {
            // Remove 'active' class to hide modal
            modal.classList.remove('active');
            // Restore body scroll
            document.body.style.overflow = '';
        }
    }
    
    // Close modal when clicking on X or Cancel
    $scope.closeModal = closeModal;
    
    // ============================================================
    // 🔹 INITIALIZE
    // ============================================================
    
    $scope.loadRoles();
    $scope.loadPermissions();
}]);
