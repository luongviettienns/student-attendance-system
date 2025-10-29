// Dashboard Controller
app.controller('DashboardController', ['$scope', '$q', '$timeout', 'AuthService', 'UserService', 'FacultyService', 'StudentService', 'SubjectService', 'LecturerService', 'MajorService', 'AcademicYearService', 'ApiService', 'ToastService',
    function($scope, $q, $timeout, AuthService, UserService, FacultyService, StudentService, SubjectService, LecturerService, MajorService, AcademicYearService, ApiService, ToastService) {
    
    $scope.currentUser = AuthService.getCurrentUser();
    $scope.stats = {
        totalUsers: 0,
        totalStudents: 0,
        totalLecturers: 0,
        totalFaculties: 0,
        totalMajors: 0,
        totalSubjects: 0,
        totalAcademicYears: 0
    };
    
    $scope.loading = true;
    $scope.error = null;
    
    // ============================================
    // 🆕 AVATAR MODAL - CLEAN IMPLEMENTATION
    // ============================================
    
    $scope.avatarModal = {
        show: false,
        selectedFile: null,
        previewUrl: null,
        error: null,
        success: null,
        uploading: false,
        dragOver: false
    };
    
    // Open modal
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
    
    // Close modal
    $scope.closeAvatarModal = function() {
        $scope.avatarModal.show = false;
        $scope.clearSelectedFile();
    };
    
    // Trigger file input
    $scope.triggerFileInput = function() {
        document.getElementById('avatarFileInput').click();
    };
    
    // Handle file selection
    $scope.handleFileSelect = function(files) {
        if (!files || files.length === 0) return;
        
        var file = files[0];
        // Validate file type
        if (!file.type.match('image.*')) {
            ToastService.warning('Vui lòng chọn file ảnh (JPG, PNG, GIF)');
            $scope.avatarModal.error = 'File không phải là ảnh';
            return;
        }
        
        // Validate file size (5MB)
        if (file.size > 5 * 1024 * 1024) {
            ToastService.warning('Kích thước file không được vượt quá 5MB');
            $scope.avatarModal.error = 'File quá lớn (tối đa 5MB)';
            return;
        }
        
        // Clear previous errors
        $scope.avatarModal.error = null;
        $scope.avatarModal.selectedFile = file;
        
        // Create preview
        var reader = new FileReader();
        reader.onload = function(e) {
            $scope.$apply(function() {
                $scope.avatarModal.previewUrl = e.target.result;
            });
        };
        reader.readAsDataURL(file);
    };
    
    // Clear selected file
    $scope.clearSelectedFile = function() {
        $scope.avatarModal.selectedFile = null;
        $scope.avatarModal.previewUrl = $scope.currentUser.avatarUrl || null;
        $scope.avatarModal.error = null;
        var fileInput = document.getElementById('avatarFileInput');
        if (fileInput) fileInput.value = '';
    };
    
    // Upload avatar
    $scope.uploadAvatar = function() {
        if (!$scope.avatarModal.selectedFile) {
            ToastService.warning('Vui lòng chọn ảnh trước khi tải lên');
            return;
        }
        
        if (!$scope.currentUser || !$scope.currentUser.userId) {
            ToastService.error('Không tìm thấy thông tin người dùng');
            return;
        }
        
        $scope.avatarModal.uploading = true;
        $scope.avatarModal.error = null;
        
        var formData = new FormData();
        formData.append('avatar', $scope.avatarModal.selectedFile);
        formData.append('userId', $scope.currentUser.userId);
        ApiService.uploadFile('/admin/users/avatar', formData)
            .then(function(response) {
                $scope.avatarModal.uploading = false;
                $scope.avatarModal.success = 'Tải ảnh thành công!';
                
                ToastService.success('Cập nhật ảnh đại diện thành công!');
                
                // Update user avatar
                if (response.data && response.data.avatarUrl) {
                    $scope.currentUser.avatarUrl = response.data.avatarUrl;
                    AuthService.updateUser($scope.currentUser);
                } else if (response.data && response.data.data && response.data.data.avatarUrl) {
                    $scope.currentUser.avatarUrl = response.data.data.avatarUrl;
                    AuthService.updateUser($scope.currentUser);
                }
                
                // Close modal after 1 second
                $timeout(function() {
                    $scope.closeAvatarModal();
                }, 1000);
            })
            .catch(function(error) {
                console.error('❌ Upload error:', error);
                
                $scope.avatarModal.uploading = false;
                
                var errorMsg = 'Có lỗi xảy ra khi tải ảnh lên';
                if (error.data && error.data.message) {
                    errorMsg = error.data.message;
                }
                
                $scope.avatarModal.error = errorMsg;
                ToastService.error(errorMsg, 5000);
            });
    };
    
    // Format file size
    $scope.formatFileSize = function(bytes) {
        if (!bytes || bytes === 0) return '0 Bytes';
        var k = 1024;
        var sizes = ['Bytes', 'KB', 'MB', 'GB'];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    };
    
    // Setup file input event listener
    $timeout(function() {
        var fileInput = document.getElementById('avatarFileInput');
        if (fileInput) {
            fileInput.addEventListener('change', function(e) {
                $scope.handleFileSelect(e.target.files);
            });
        }
        
        // Setup drag & drop
        var dropzone = document.querySelector('.avatar-upload-dropzone');
        if (dropzone) {
            dropzone.addEventListener('dragover', function(e) {
                e.preventDefault();
                e.stopPropagation();
                $scope.$apply(function() {
                    $scope.avatarModal.dragOver = true;
                });
            });
            
            dropzone.addEventListener('dragleave', function(e) {
                e.preventDefault();
                e.stopPropagation();
                $scope.$apply(function() {
                    $scope.avatarModal.dragOver = false;
                });
            });
            
            dropzone.addEventListener('drop', function(e) {
                e.preventDefault();
                e.stopPropagation();
                $scope.$apply(function() {
                    $scope.avatarModal.dragOver = false;
                    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
                        $scope.handleFileSelect(e.dataTransfer.files);
                    }
                });
            });
        }
    }, 0);
    
    // Helper function to extract count from response
    function getCountFromResponse(response) {
        if (!response || !response.data) return 0;
        
        // Check if it's pagination response
        if (response.data.pagination && response.data.pagination.totalCount) {
            return response.data.pagination.totalCount;
        }
        
        // Check if it's array directly
        if (Array.isArray(response.data)) {
            return response.data.length;
        }
        
        // Check if it's wrapped in data property
        if (response.data.data) {
            if (Array.isArray(response.data.data)) {
                return response.data.data.length;
            }
        }
        
        return 0;
    }
    
    // Load all statistics
    $scope.loadStats = function() {
        $scope.loading = true;
        $scope.error = null;
        
        // Create promises for all API calls
        var promises = {
            users: UserService.getAll().catch(function(err) { 
                console.error('Error loading users:', err);
                return {data: []};
            }),
            students: StudentService.getAll().catch(function(err) { 
                console.error('Error loading students:', err);
                return {data: []};
            }),
            lecturers: LecturerService.getAll().catch(function(err) { 
                console.error('Error loading lecturers:', err);
                return {data: []};
            }),
            faculties: FacultyService.getAll().catch(function(err) { 
                console.error('Error loading faculties:', err);
                return {data: []};
            }),
            majors: MajorService.getAll().catch(function(err) { 
                console.error('Error loading majors:', err);
                return {data: []};
            }),
            subjects: SubjectService.getAll().catch(function(err) { 
                console.error('Error loading subjects:', err);
                return {data: []};
            }),
            academicYears: AcademicYearService.getAll().catch(function(err) { 
                console.error('Error loading academic years:', err);
                return {data: []};
            })
        };
        
        // Wait for all promises to complete
        $q.all(promises).then(function(results) {
            $scope.stats.totalUsers = getCountFromResponse(results.users);
            $scope.stats.totalStudents = getCountFromResponse(results.students);
            $scope.stats.totalLecturers = getCountFromResponse(results.lecturers);
            $scope.stats.totalFaculties = getCountFromResponse(results.faculties);
            $scope.stats.totalMajors = getCountFromResponse(results.majors);
            $scope.stats.totalSubjects = getCountFromResponse(results.subjects);
            $scope.stats.totalAcademicYears = getCountFromResponse(results.academicYears);
            $scope.loading = false;
        }).catch(function(error) {
            console.error('Error loading dashboard stats:', error);
            $scope.error = 'Không thể tải dữ liệu thống kê';
            $scope.loading = false;
        });
    };
    
    // Logout
    $scope.logout = function() {
        ToastService.info('Đang đăng xuất...');
        
        // Small delay for toast to show
        $timeout(function() {
            AuthService.logout();
        }, 300);
    };
    
    // Initialize
    $scope.loadStats();
}]);

