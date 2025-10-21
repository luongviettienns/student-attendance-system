// Role Controller
app.controller('RoleController', ['$scope', 'UserService', 'AuthService', 'AvatarService', function($scope, UserService, AuthService, AvatarService) {
    
    $scope.roles = [];
    $scope.loading = false;
    $scope.error = null;
    
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
    
    // Load all roles
    $scope.loadRoles = function() {
        $scope.loading = true;
        UserService.getRoles()
            .then(function(response) {
                $scope.roles = response.data;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = 'Không thể tải danh sách vai trò';
                $scope.loading = false;
            });
    };
    
    // Initialize
    $scope.loadRoles();
}]);

