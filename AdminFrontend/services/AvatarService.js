// Avatar Service - Reusable avatar upload functionality
app.service('AvatarService', ['$timeout', 'ApiService', 'AuthService', function($timeout, ApiService, AuthService) {
    
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
                previewUrl: $scope.currentUser.avatarUrl || null,
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
                $scope.avatarModal.error = 'Vui lòng chọn file ảnh (JPG, PNG, GIF)';
                if (!$scope.$$phase) $scope.$apply();
                return;
            }
            
            // Validate file size (5MB)
            if (file.size > 5 * 1024 * 1024) {
                $scope.avatarModal.error = 'Kích thước file không được vượt quá 5MB';
                if (!$scope.$$phase) $scope.$apply();
                return;
            }
            
            $scope.avatarModal.selectedFile = file;
            $scope.avatarModal.error = null;
            
            // Create preview
            var reader = new FileReader();
            reader.onload = function(e) {
                $scope.$apply(function() {
                    $scope.avatarModal.previewUrl = e.target.result;
                });
            };
            reader.readAsDataURL(file);
            
            if (!$scope.$$phase) {
                $scope.$apply();
            }
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
            if (!$scope.avatarModal.selectedFile) return;
            
            $scope.avatarModal.uploading = true;
            $scope.avatarModal.error = null;
            $scope.avatarModal.success = null;
            
            var formData = new FormData();
            formData.append('avatar', $scope.avatarModal.selectedFile);
            formData.append('userId', $scope.currentUser.userId);
            
            // Make API call to upload avatar
            ApiService.uploadFile('/users/avatar', formData)
                .then(function(response) {
                    $scope.avatarModal.uploading = false;
                    $scope.avatarModal.success = 'Cập nhật ảnh đại diện thành công!';
                    
                    // Update current user avatar
                    if (response.data && response.data.avatarUrl) {
                        $scope.currentUser.avatarUrl = response.data.avatarUrl;
                        AuthService.updateUser($scope.currentUser);
                    }
                    
                    // Close modal after 1.5 seconds
                    $timeout(function() {
                        $scope.closeAvatarModal();
                    }, 1500);
                })
                .catch(function(error) {
                    $scope.avatarModal.uploading = false;
                    $scope.avatarModal.error = error.message || 'Có lỗi xảy ra khi tải ảnh lên';
                    console.error('Error uploading avatar:', error);
                });
        };
    };
}]);

