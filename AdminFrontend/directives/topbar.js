// Topbar Directive - Consistent header across all views
app.directive('appTopbar', ['AuthService', function(AuthService) {
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
        }
    };
}]);


