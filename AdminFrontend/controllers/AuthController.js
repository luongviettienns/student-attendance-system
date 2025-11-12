// ============================================================
// AUTH CONTROLLERS - Forgot Password Flow (OTP-based)
// ============================================================

// Step 1: Forgot Password - Send OTP
app.controller('ForgotPasswordController', ['$scope', '$location', '$timeout', 'AuthService',
    function($scope, $location, $timeout, AuthService) {
    
    $scope.email = '';
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.otpSent = false;
    $scope.resendCooldown = 0;
    
    // Send OTP to email
    $scope.sendOTP = function() {
        if (!$scope.email || !$scope.email.trim()) {
            $scope.error = 'Vui lòng nhập email';
            return;
        }
        
        $scope.error = null;
        $scope.success = null;
        $scope.loading = true;
        
        AuthService.forgotPassword($scope.email.trim())
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.otpSent = true;
                    $scope.success = response.data.message || 'Mã OTP đã được gửi đến email của bạn.';
                    $scope.resendCooldown = 60; // 60 seconds cooldown
                    startResendCooldown();
                } else {
                    $scope.error = response.data?.message || 'Không thể gửi mã OTP. Vui lòng thử lại.';
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể gửi mã OTP. Vui lòng thử lại.';
                $scope.loading = false;
            });
    };
    
    // Resend OTP
    $scope.resendOTP = function() {
        if ($scope.resendCooldown > 0) return;
        $scope.sendOTP();
    };
    
    // Start resend cooldown timer
    function startResendCooldown() {
        if ($scope.resendCooldown > 0) {
            $timeout(function() {
                $scope.resendCooldown--;
                if ($scope.resendCooldown > 0) {
                    startResendCooldown();
                }
            }, 1000);
        }
    }
    
    // Navigate to verify OTP page
    $scope.goToVerifyOTP = function() {
        $location.path('/verify-otp').search({ email: $scope.email });
    };
}]);

// Step 2: Verify OTP
app.controller('VerifyOTPController', ['$scope', '$location', '$timeout', '$interval', 'AuthService',
    function($scope, $location, $timeout, $interval, AuthService) {
    
    $scope.email = $location.search().email || '';
    $scope.otpDigits = ['', '', '', ''];
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.otpVerified = false;
    $scope.remainingSeconds = 0;
    $scope.resendCooldown = 0;
    var countdownInterval = null;
    
    // Initialize countdown
    function startCountdown() {
        if (countdownInterval) {
            $interval.cancel(countdownInterval);
        }
        
        countdownInterval = $interval(function() {
            if ($scope.remainingSeconds > 0) {
                $scope.remainingSeconds--;
            } else {
                $interval.cancel(countdownInterval);
            }
        }, 1000);
    }
    
    // Load remaining time from server
    function loadRemainingTime() {
        if (!$scope.email) return;
        
        AuthService.getOTPRemainingTime($scope.email)
            .then(function(response) {
                if (response.data && response.data.success && response.data.remainingSeconds > 0) {
                    $scope.remainingSeconds = response.data.remainingSeconds;
                    startCountdown();
                } else {
                    $scope.remainingSeconds = 0;
                }
            })
            .catch(function(error) {
                console.error('Error loading OTP remaining time:', error);
                $scope.remainingSeconds = 0;
            });
    }
    
    // Format time as MM:SS
    $scope.formatTime = function(seconds) {
        var mins = Math.floor(seconds / 60);
        var secs = seconds % 60;
        return (mins < 10 ? '0' : '') + mins + ':' + (secs < 10 ? '0' : '') + secs;
    };
    
    // Move to next OTP input field
    $scope.moveToNext = function(event, index) {
        var key = event.keyCode || event.which;
        
        // Only allow numbers
        if (key < 48 || key > 57) {
            if (key !== 8 && key !== 46 && key !== 37 && key !== 39) {
                event.preventDefault();
            }
            return;
        }
        
        // Auto-move to next field
        if (index < 3 && $scope.otpDigits[index]) {
            var nextInput = document.getElementById('otp-' + (index + 1));
            if (nextInput) {
                $timeout(function() {
                    nextInput.focus();
                }, 10);
            }
        }
    };
    
    // Check if OTP is complete (all 4 digits filled)
    $scope.isOTPComplete = function() {
        return $scope.otpDigits.every(function(digit) {
            return digit && digit.length === 1;
        });
    };
    
    // Verify OTP
    $scope.verifyOTP = function() {
        var otp = $scope.otpDigits.join('');
        
        if (otp.length !== 4) {
            $scope.error = 'Vui lòng nhập đầy đủ 4 số OTP';
            return;
        }
        
        if ($scope.remainingSeconds === 0) {
            $scope.error = 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.';
            return;
        }
        
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.verifyOTP($scope.email, otp)
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.otpVerified = true;
                    $scope.success = response.data.message || 'Mã OTP hợp lệ.';
                    if (countdownInterval) {
                        $interval.cancel(countdownInterval);
                    }
                } else {
                    $scope.error = response.data?.message || 'Mã OTP không đúng. Vui lòng thử lại.';
                    // Clear OTP inputs on error
                    $scope.otpDigits = ['', '', '', ''];
                    $timeout(function() {
                        document.getElementById('otp-0')?.focus();
                    }, 100);
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Mã OTP không đúng. Vui lòng thử lại.';
                $scope.loading = false;
                // Clear OTP inputs on error
                $scope.otpDigits = ['', '', '', ''];
                $timeout(function() {
                    document.getElementById('otp-0')?.focus();
                }, 100);
            });
    };
    
    // Resend OTP
    $scope.resendOTP = function() {
        if ($scope.resendCooldown > 0) return;
        
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.forgotPassword($scope.email)
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.success = 'Mã OTP mới đã được gửi đến email của bạn.';
                    $scope.remainingSeconds = 300; // Reset to 5 minutes
                    $scope.resendCooldown = 60;
                    startCountdown();
                    startResendCooldown();
                    // Clear OTP inputs
                    $scope.otpDigits = ['', '', '', ''];
                    $timeout(function() {
                        document.getElementById('otp-0')?.focus();
                    }, 100);
                } else {
                    $scope.error = response.data?.message || 'Không thể gửi mã OTP. Vui lòng thử lại.';
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể gửi mã OTP. Vui lòng thử lại.';
                $scope.loading = false;
            });
    };
    
    // Start resend cooldown timer
    function startResendCooldown() {
        if ($scope.resendCooldown > 0) {
            $timeout(function() {
                $scope.resendCooldown--;
                if ($scope.resendCooldown > 0) {
                    startResendCooldown();
                }
            }, 1000);
        }
    }
    
    // Navigate to reset password page
    $scope.goToResetPassword = function() {
        $location.path('/reset-password').search({ email: $scope.email });
    };
    
    // Initialize
    if (!$scope.email) {
        $location.path('/forgot-password');
        return;
    }
    
    // Load remaining time from server
    loadRemainingTime();
    
    // Cleanup on destroy
    $scope.$on('$destroy', function() {
        if (countdownInterval) {
            $interval.cancel(countdownInterval);
        }
    });
}]);

// Step 3: Reset Password
app.controller('ResetPasswordController', ['$scope', '$location', '$timeout', 'AuthService',
    function($scope, $location, $timeout, AuthService) {
    
    $scope.email = $location.search().email || '';
    $scope.newPassword = '';
    $scope.confirmPassword = '';
    $scope.showPassword = false;
    $scope.showConfirmPassword = false;
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.passwordReset = false;
    $scope.passwordStrength = null;
    
    // Password strength calculator
    $scope.$watch('newPassword', function(newVal) {
        if (!newVal) {
            $scope.passwordStrength = null;
            return;
        }
        
        var strength = 0;
        
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
    
    // Reset Password
    $scope.resetPassword = function() {
        if ($scope.newPassword !== $scope.confirmPassword) {
            $scope.error = 'Mật khẩu xác nhận không khớp';
            return;
        }
        
        if ($scope.newPassword.length < 6) {
            $scope.error = 'Mật khẩu phải có ít nhất 6 ký tự';
            return;
        }
        
        $scope.error = null;
        $scope.loading = true;
        
        AuthService.resetPassword($scope.email, $scope.newPassword, $scope.confirmPassword)
            .then(function(response) {
                if (response.data && response.data.success) {
                    $scope.passwordReset = true;
                    $scope.success = response.data.message || 'Đặt lại mật khẩu thành công.';
                } else {
                    $scope.error = response.data?.message || 'Không thể đặt lại mật khẩu. Vui lòng thử lại.';
                }
                $scope.loading = false;
            })
            .catch(function(error) {
                $scope.error = error.data?.message || 'Không thể đặt lại mật khẩu. Vui lòng thử lại.';
                $scope.loading = false;
            });
    };
    
    // Initialize
    if (!$scope.email) {
        $location.path('/forgot-password');
        return;
    }
}]);
