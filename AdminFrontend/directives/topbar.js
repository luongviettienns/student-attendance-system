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
            
            // ✅ CRITICAL: Force close modal on initialization to prevent auto-open
            scope.$watch(function() {
                return scope.avatarModal;
            }, function(newVal, oldVal) {
                // Prevent modal from auto-opening - only allow explicit open
                if (newVal && newVal.show && !scope._explicitModalOpen) {
                    // Modal was opened without explicit user action - close it
                    scope.avatarModal.show = false;
                    // Remove active class from DOM
                    setTimeout(function() {
                        var modalElement = document.querySelector('.avatar-modal.modal-overlay');
                        if (modalElement) {
                            modalElement.classList.remove('active');
                        }
                    }, 0);
                }
            }, true);
            
            // ✅ Override openAvatarModal to track explicit opens
            var originalOpenAvatarModal = scope.openAvatarModal;
            scope.openAvatarModal = function(event) {
                scope._explicitModalOpen = true;
                if (originalOpenAvatarModal) {
                    originalOpenAvatarModal(event);
                }
                // Reset flag after a delay
                setTimeout(function() {
                    scope._explicitModalOpen = false;
                }, 100);
            };
            
            // ✅ Ensure modal is closed when route changes (prevent auto-open)
            scope.$on('$routeChangeSuccess', function() {
                scope._explicitModalOpen = false;
                if (scope.avatarModal) {
                    scope.avatarModal.show = false;
                }
                // Force remove active class
                setTimeout(function() {
                    var modalElement = document.querySelector('.avatar-modal.modal-overlay');
                    if (modalElement) {
                        modalElement.classList.remove('active');
                    }
                }, 0);
            });
            
            // ✅ Ensure modal is closed when user logs in (prevent auto-open after login)
            scope.$on('user:logout', function() {
                scope._explicitModalOpen = false;
                if (scope.avatarModal) {
                    scope.avatarModal.show = false;
                }
            });
            
            // ✅ Add logout function
            scope.logout = function() {
                AuthService.logout();
            };
        }
    };
}]);


