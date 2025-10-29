// Avatar Service - Reusable avatar upload functionality
app.service('AvatarService', ['$timeout', 'ApiService', 'AuthService', 'ToastService', function($timeout, ApiService, AuthService, ToastService) {
    
    // Initialize avatar modal functions for a scope
    this.initAvatarModal = function($scope) {
        // Avatar Modal State
        $scope.avatarModal = {
            show: false,
            selectedFile: null,
            previewUrl: null,
            error: null,
            success: null,
            uploading: false,
            dragOver: false
        };
        
        // Open Avatar Modal
        $scope.openAvatarModal = function() {
            $scope.avatarModal = {
                show: true,
                selectedFile: null,
                previewUrl: $scope.currentUser ? ($scope.currentUser.avatarUrl || null) : null,
                error: null,
                success: null,
                uploading: false,
                dragOver: false
            };
        };
        
        // Close Avatar Modal
        $scope.closeAvatarModal = function() {
            $scope.avatarModal.show = false;
            $scope.avatarModal.selectedFile = null;
            $scope.avatarModal.previewUrl = null;
            $scope.avatarModal.error = null;
            $scope.avatarModal.success = null;
        };
        
        // Trigger File Input
        $scope.triggerFileInput = function() {
            document.getElementById('avatarFileInput').click();
        };
        
        // Handle File Selection
        $scope.handleFileSelect = function(files) {
            if (!files || files.length === 0) return;
            
            var file = files[0];
            
            // Validate file type
            if (!file.type.match('image.*')) {
                var errorMsg = 'Vui lòng chọn file ảnh (JPG, PNG, GIF)';
                ToastService.warning(errorMsg);
                $scope.$evalAsync(function() {
                    $scope.avatarModal.error = errorMsg;
                });
                return;
            }
            
            // Validate file size (5MB)
            if (file.size > 5 * 1024 * 1024) {
                var errorMsg = 'Kích thước file không được vượt quá 5MB';
                ToastService.warning(errorMsg);
                $scope.$evalAsync(function() {
                    $scope.avatarModal.error = errorMsg;
                });
                return;
            }
            
            // Create preview
            var reader = new FileReader();
            reader.onload = function(e) {
                $scope.$evalAsync(function() {
                    $scope.avatarModal.selectedFile = file;
                    $scope.avatarModal.error = null;
                    $scope.avatarModal.previewUrl = e.target.result;
                });
            };
            reader.readAsDataURL(file);
        };
        
        // Clear Selected File
        $scope.clearSelectedFile = function() {
            $scope.avatarModal.selectedFile = null;
            $scope.avatarModal.previewUrl = $scope.currentUser.avatarUrl || null;
            $scope.avatarModal.error = null;
            document.getElementById('avatarFileInput').value = '';
        };
        
        // Format File Size
        $scope.formatFileSize = function(bytes) {
            if (!bytes) return '0 Bytes';
            var k = 1024;
            var sizes = ['Bytes', 'KB', 'MB', 'GB'];
            var i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        };
        
        // Handle Drag Over
        $scope.handleDragOver = function(event) {
            event.preventDefault();
            event.stopPropagation();
            $scope.avatarModal.dragOver = true;
        };
        
        // Handle Drag Leave
        $scope.handleDragLeave = function(event) {
            event.preventDefault();
            event.stopPropagation();
            $scope.avatarModal.dragOver = false;
        };
        
        // Handle Drop
        $scope.handleDrop = function(event) {
            event.preventDefault();
            event.stopPropagation();
            $scope.avatarModal.dragOver = false;
            
            var files = event.dataTransfer.files;
            $scope.handleFileSelect(files);
        };
        
        // Upload Avatar
        $scope.uploadAvatar = function() {
            if (!$scope.avatarModal.selectedFile) {
                ToastService.warning('Vui lòng chọn ảnh trước khi tải lên');
                return;
            }
            
            if (!$scope.currentUser || !$scope.currentUser.userId) {
                ToastService.error('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.');
                return;
            }
            
            $scope.avatarModal.uploading = true;
            $scope.avatarModal.error = null;
            $scope.avatarModal.success = null;
            
            var formData = new FormData();
            formData.append('avatar', $scope.avatarModal.selectedFile);
            formData.append('userId', $scope.currentUser.userId);
            
            // Make API call to upload avatar
            ApiService.uploadFile('/admin/users/avatar', formData)
                .then(function(response) {
                    $scope.avatarModal.uploading = false;
                    
                    // Show success toast
                    ToastService.success('Cập nhật ảnh đại diện thành công!');
                    
                    // Update current user avatar
                    if (response.data) {
                        var newAvatarUrl = response.data.avatarUrl || 
                                          (response.data.data && response.data.data.avatarUrl);
                        if (newAvatarUrl) {
                            $scope.currentUser.avatarUrl = newAvatarUrl;
                            AuthService.updateUser($scope.currentUser);
                        }
                    }
                    
                    // Close modal after 800ms
                    $timeout(function() {
                        $scope.closeAvatarModal();
                    }, 800);
                })
                .catch(function(error) {
                    $scope.avatarModal.uploading = false;
                    
                    // Extract error message
                    var errorMessage = 'Có lỗi xảy ra khi tải ảnh lên';
                    if (error.data && error.data.message) {
                        errorMessage = error.data.message;
                    } else if (error.message) {
                        errorMessage = error.message;
                    } else if (error.statusText) {
                        errorMessage = 'Lỗi: ' + error.statusText;
                    }
                    
                    // Show error toast
                    ToastService.error(errorMessage, 5000);
                    
                    // Also show in modal
                    $scope.avatarModal.error = errorMessage;
                });
        };
        
        // Format File Size Helper
        $scope.formatFileSize = function(bytes) {
            if (!bytes || bytes === 0) return '0 Bytes';
            var k = 1024;
            var sizes = ['Bytes', 'KB', 'MB', 'GB'];
            var i = Math.floor(Math.log(bytes) / Math.log(k));
            return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
        };
    };
}]);

