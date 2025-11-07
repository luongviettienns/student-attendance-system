// Route Guard - Simple authentication check for student portal
app.run(['$rootScope', '$location', 'AuthService', 'ToastService', 
    function($rootScope, $location, AuthService, ToastService) {
    
    // Public routes (no login required)
    var publicRoutes = ['/login', '/forgot-password', '/reset-password'];
    
    // Listen for route changes
    $rootScope.$on('$locationChangeStart', function(event, next, current) {
        var path = $location.path();
        
        // Allow public routes
        if (publicRoutes.some(function(route) { return path.indexOf(route) === 0; })) {
            return;
        }
        
        // Check authentication
        if (!AuthService.isLoggedIn()) {
            event.preventDefault();
            $location.path('/login');
            ToastService.warning('Vui lòng đăng nhập để tiếp tục');
            return;
        }
    });
}]);


