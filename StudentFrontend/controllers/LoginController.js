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
                
                // Redirect to dashboard (student portal)
                $location.path('/dashboard');
            })
            .catch(function(error) {
                console.error('Login failed:', error);
                $scope.loading = false;
                $scope.error = 'Tên đăng nhập hoặc mật khẩu không đúng';
            });
    };
}]);


