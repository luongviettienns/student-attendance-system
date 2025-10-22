// Login Controller
app.controller('LoginController', ['$scope', '$location', 'AuthService', function($scope, $location, AuthService) {
    $scope.credentials = {
        username: '',
        password: '',
        rememberMe: false
    };
    
    $scope.error = null;
    $scope.loading = false;
    $scope.showPassword = false; // Toggle password visibility
    
    $scope.login = function() {
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.login($scope.credentials.username, $scope.credentials.password, $scope.credentials.rememberMe)
            .then(function(response) {
                $scope.loading = false;
                
                // Redirect based on user role
                var roleName = response.roleName || 'Admin';
                
                switch(roleName) {
                    case 'Lecturer':
                        $location.path('/lecturer/dashboard');
                        break;
                    case 'Advisor':
                        $location.path('/advisor/dashboard');
                        break;
                    case 'Student':
                        $location.path('/student/dashboard');
                        break;
                    case 'Admin':
                    default:
                        $location.path('/dashboard');
                        break;
                }
            })
            .catch(function(error) {
                console.error('Login failed:', error);
                $scope.loading = false;
                $scope.error = 'Tên đăng nhập hoặc mật khẩu không đúng';
            });
    };
}]);

