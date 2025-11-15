// Topbar Directive - Consistent header across all views
app.directive('appTopbar', ['AuthService', 'AvatarService', function(AuthService, AvatarService) {
    return {
        restrict: 'E',
        scope: {
            pageTitle: '@'
        },
        templateUrl: 'views/partials/topbar.html',
        link: function(scope) {
            function loadCurrentUser() {
                scope.currentUser = AuthService.getCurrentUser() || { fullName: 'Admin' };
            }

            loadCurrentUser();

            scope.$on('$routeChangeSuccess', function() {
                loadCurrentUser();
            });
            
            // ✅ Listen for avatar updates
            scope.$on('userAvatarUpdated', function(event, newAvatarUrl) {
                if (scope.currentUser) {
                    scope.currentUser.avatarUrl = newAvatarUrl;
                }
            });
            
            // ✅ Initialize Avatar Modal
            AvatarService.initAvatarModal(scope);
            
            // ✅ Add logout function
            scope.logout = function() {
                AuthService.logout();
            };
        }
    };
}]);


