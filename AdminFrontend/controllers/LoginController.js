// Login Controller
app.controller('LoginController', ['$scope', '$location', 'AuthService', function($scope, $location, AuthService) {
    console.log('LoginController initialized');
    
    $scope.credentials = {
        username: '',
        password: '',
        rememberMe: false
    };
    
    $scope.error = null;
    $scope.loading = false;
    
    $scope.login = function() {
        console.log('Login function called with:', $scope.credentials);
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.login($scope.credentials.username, $scope.credentials.password, $scope.credentials.rememberMe)
            .then(function(response) {
                console.log('Login successful:', response);
                $scope.loading = false;
                
                // Redirect based on user role
                var roleName = response.roleName || 'Admin';
                console.log('User role:', roleName);
                
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
    
    console.log('LoginController scope:', $scope);
}]);

