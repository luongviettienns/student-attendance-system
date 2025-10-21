// Auth Controller - Forgot Password & Reset Password
app.controller('ForgotPasswordController', ['$scope', '$location', 'AuthService',
    function($scope, $location, AuthService) {
    
    $scope.email = '';
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.emailSent = false;
    
    $scope.sendResetLink = function() {
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.forgotPassword($scope.email)
            .then(function(response) {
                $scope.emailSent = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể gửi email. Vui lòng thử lại.';
                $scope.loading = false;
            });
    };
}]);

app.controller('ResetPasswordController', ['$scope', '$location', '$routeParams', 'AuthService',
    function($scope, $location, $routeParams, AuthService) {
    
    $scope.token = $routeParams.token;
    $scope.password = '';
    $scope.confirmPassword = '';
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.tokenValid = true;
    $scope.passwordReset = false;
    
    // Password strength calculator
    $scope.$watch('password', function(newVal) {
        if (!newVal) {
            $scope.passwordStrength = null;
            return;
        }
        
        var strength = 0;
        var feedback = '';
        
        if (newVal.length >= 6) strength += 25;
        if (newVal.length >= 10) strength += 25;
        if (/[a-z]/.test(newVal) && /[A-Z]/.test(newVal)) strength += 25;
        if (/\d/.test(newVal)) strength += 15;
        if (/[^a-zA-Z0-9]/.test(newVal)) strength += 10;
        
        if (strength < 40) {
            $scope.passwordStrength = {
                class: 'weak',
                width: strength + '%',
                text: 'Yếu - Cần mật khẩu mạnh hơn'
            };
        } else if (strength < 70) {
            $scope.passwordStrength = {
                class: 'medium',
                width: strength + '%',
                text: 'Trung bình - Có thể tốt hơn'
            };
        } else {
            $scope.passwordStrength = {
                class: 'strong',
                width: '100%',
                text: 'Mạnh - Mật khẩu tốt'
            };
        }
    });
    
    // Validate token on load
    $scope.validateToken = function() {
        if (!$scope.token) {
            $scope.tokenValid = false;
            return;
        }
        
        AuthService.validateResetToken($scope.token)
            .then(function(response) {
                $scope.tokenValid = true;
            })
            .catch(function(error) {
                $scope.tokenValid = false;
            });
    };
    
    $scope.resetPassword = function() {
        if ($scope.password !== $scope.confirmPassword) {
            $scope.error = 'Mật khẩu không khớp';
            return;
        }
        
        if ($scope.password.length < 6) {
            $scope.error = 'Mật khẩu phải có ít nhất 6 ký tự';
            return;
        }
        
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.resetPassword($scope.token, $scope.password)
            .then(function(response) {
                $scope.passwordReset = true;
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể đặt lại mật khẩu. Vui lòng thử lại.';
                $scope.loading = false;
            });
    };
    
    // Initialize
    $scope.validateToken();
}]);

