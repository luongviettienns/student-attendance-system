// Student Topbar Directive
app.directive('appTopbar', ['AuthService', 'AvatarService', function(AuthService, AvatarService) {
    return {
        restrict: 'E',
        scope: {
            pageTitle: '@'
        },
        templateUrl: 'views/partials/topbar.html',
        link: function(scope) {
            function loadCurrentUser() {
                scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Sinh viên' };
            }

            loadCurrentUser();

            scope.$on('$routeChangeSuccess', function() {
                loadCurrentUser();
            });
            
            // Initialize Avatar Modal
            AvatarService.initAvatarModal(scope);
            
            // Add logout function
            scope.logout = function() {
                AuthService.logout();
            };
        }
    };
}]);


