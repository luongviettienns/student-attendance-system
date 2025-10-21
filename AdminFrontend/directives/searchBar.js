// Search Bar Directive
app.directive('searchBar', ['$timeout', function($timeout) {
    return {
        restrict: 'E',
        scope: {
            placeholder: '@',
            searchTerm: '=',
            onSearch: '&'
        },
        template: 
            '<div class="search-bar">' +
                '<div class="search-input-group">' +
                    '<i class="fas fa-search search-icon"></i>' +
                    '<input type="text" ' +
                           'ng-model="searchTerm" ' +
                           'ng-change="handleSearch()" ' +
                           'placeholder="{{placeholder || \'Tìm kiếm...\'}}" ' +
                           'class="search-input">' +
                    '<button ng-if="searchTerm" ng-click="clearSearch()" class="search-clear">' +
                        '<i class="fas fa-times"></i>' +
                    '</button>' +
                '</div>' +
            '</div>',
        link: function(scope) {
            var searchTimeout;
            
            scope.handleSearch = function() {
                // Debounce search - wait 500ms after user stops typing
                if (searchTimeout) {
                    $timeout.cancel(searchTimeout);
                }
                
                searchTimeout = $timeout(function() {
                    scope.onSearch();
                }, 500);
            };
            
            scope.clearSearch = function() {
                scope.searchTerm = '';
                scope.onSearch();
            };
        }
    };
}]);

