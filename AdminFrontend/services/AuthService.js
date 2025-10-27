// Authentication Service
app.service('AuthService', ['$http', '$window', '$location', '$rootScope', 'API_CONFIG', function($http, $window, $location, $rootScope, API_CONFIG) {
    var TOKEN_KEY = 'auth_token';
    var USER_KEY = 'user_info';
    
    // Helper function to get the appropriate storage
    var getStorage = function() {
        // Check if we have data in localStorage first (remember me was checked)
        if ($window.localStorage.getItem(TOKEN_KEY)) {
            return $window.localStorage;
        }
        // Otherwise use sessionStorage
        return $window.sessionStorage;
    };
    
    this.login = function(username, password, rememberMe) {
        return $http.post(API_CONFIG.BASE_URL + '/auth/login', {
            username: username,
            password: password
        }).then(function(response) {
            if (response.data && response.data.data) {
                var loginData = response.data.data;
                
                // Choose storage based on rememberMe
                var storage = rememberMe ? $window.localStorage : $window.sessionStorage;
                
                // Clear any existing tokens from both storages
                $window.localStorage.removeItem(TOKEN_KEY);
                $window.localStorage.removeItem(USER_KEY);
                $window.sessionStorage.removeItem(TOKEN_KEY);
                $window.sessionStorage.removeItem(USER_KEY);
                
                // Save to the chosen storage
                storage.setItem(TOKEN_KEY, loginData.token);
                storage.setItem(USER_KEY, JSON.stringify(loginData));
                
                return loginData;
            }
            throw new Error('Invalid response format');
        });
    };
    
    this.logout = function() {
        // Broadcast logout event (for RoleService to clear cache)
        $rootScope.$broadcast('user:logout');
        
        // Clear from both storages
        $window.localStorage.removeItem(TOKEN_KEY);
        $window.localStorage.removeItem(USER_KEY);
        $window.sessionStorage.removeItem(TOKEN_KEY);
        $window.sessionStorage.removeItem(USER_KEY);
        
        // Redirect to login page
        $location.path('/login');
    };
    
    this.getToken = function() {
        // Check both storages
        return $window.localStorage.getItem(TOKEN_KEY) || 
               $window.sessionStorage.getItem(TOKEN_KEY);
    };
    
    this.getCurrentUser = function() {
        // Check both storages
        var userJson = $window.localStorage.getItem(USER_KEY) || 
                      $window.sessionStorage.getItem(USER_KEY);
        return userJson ? JSON.parse(userJson) : null;
    };
    
    this.isAuthenticated = function() {
        return !!this.getToken();
    };
    
    // Alias for isAuthenticated (used by RouteGuard)
    this.isLoggedIn = function() {
        return this.isAuthenticated();
    };
    
    // Forgot Password
    this.forgotPassword = function(email) {
        return $http.post(API_CONFIG.BASE_URL + '/auth/forgot-password', {
            email: email
        });
    };
    
    // Validate Reset Token
    this.validateResetToken = function(token) {
        return $http.get(API_CONFIG.BASE_URL + '/auth/validate-reset-token/' + token);
    };
    
    // Reset Password
    this.resetPassword = function(token, newPassword) {
        return $http.post(API_CONFIG.BASE_URL + '/auth/reset-password', {
            token: token,
            newPassword: newPassword
        });
    };
    
    // Change Password (for logged in users)
    this.changePassword = function(currentPassword, newPassword) {
        return $http.post(API_CONFIG.BASE_URL + '/auth/change-password', {
            currentPassword: currentPassword,
            newPassword: newPassword
        });
    };
    
    // Update User Info (in storage)
    this.updateUser = function(userData) {
        var storage = getStorage();
        storage.setItem(USER_KEY, JSON.stringify(userData));
    };
}]);

