// @ts-check
/* global angular */
'use strict';

// Student Grades Controller
app.controller('StudentGradesController', [
    '$scope',
    'AuthService',
    'GradeDashboardService',
    'ToastService',
    function(
        $scope,
        AuthService,
        GradeDashboardService,
        ToastService
    ) {
        $scope.currentUser = AuthService.getCurrentUser();

        var viewModel = GradeDashboardService.create($scope, {
            allowRecalculate: true,
            currentUserGetter: function() {
                return AuthService.getCurrentUser();
            },
            onError: function(message) {
                ToastService.error(message);
            }
        });

        viewModel.init();
    }
]);
