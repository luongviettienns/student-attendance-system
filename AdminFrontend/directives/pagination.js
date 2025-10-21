// Pagination Directive - Reusable pagination component
app.directive('pagination', function() {
    return {
        restrict: 'E',
        scope: {
            pagination: '=',
            onPageChange: '&'
        },
        template: 
            '<div class="pagination-container">' +
                '<div class="pagination-info">' +
                    '<span ng-if="pagination.totalItems > 0">Hiển thị {{pagination.startItem}}-{{pagination.endItem}} / {{pagination.totalItems}}</span>' +
                    '<span ng-if="pagination.totalItems === 0">Không có dữ liệu</span>' +
                '</div>' +
                '<div class="pagination-controls">' +
                    '<select ng-model="pagination.pageSize" ng-change="changePageSize()" class="page-size-select">' +
                        '<option ng-repeat="size in pagination.pageSizeOptions" value="{{size}}">{{size}} / trang</option>' +
                    '</select>' +
                    '<div class="pagination-buttons">' +
                        '<button ng-click="goToPage(1)" ng-disabled="pagination.currentPage === 1" class="btn btn-sm">' +
                            '<i class="fas fa-angle-double-left"></i>' +
                        '</button>' +
                        '<button ng-click="goToPage(pagination.currentPage - 1)" ng-disabled="pagination.currentPage === 1" class="btn btn-sm">' +
                            '<i class="fas fa-angle-left"></i>' +
                        '</button>' +
                        '<button ng-repeat="page in pageNumbers" ' +
                                'ng-click="goToPage(page)" ' +
                                'ng-class="{\'active\': page === pagination.currentPage}" ' +
                                'class="btn btn-sm page-number">' +
                            '{{page}}' +
                        '</button>' +
                        '<button ng-click="goToPage(pagination.currentPage + 1)" ng-disabled="pagination.currentPage === pagination.totalPages" class="btn btn-sm">' +
                            '<i class="fas fa-angle-right"></i>' +
                        '</button>' +
                        '<button ng-click="goToPage(pagination.totalPages)" ng-disabled="pagination.currentPage === pagination.totalPages" class="btn btn-sm">' +
                            '<i class="fas fa-angle-double-right"></i>' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>',
        link: function(scope) {
            // Calculate page numbers
            scope.updatePageNumbers = function() {
                var pages = [];
                var maxPages = 5;
                var startPage, endPage;
                
                if (scope.pagination.totalPages <= maxPages) {
                    startPage = 1;
                    endPage = scope.pagination.totalPages;
                } else {
                    if (scope.pagination.currentPage <= 3) {
                        startPage = 1;
                        endPage = maxPages;
                    } else if (scope.pagination.currentPage + 2 >= scope.pagination.totalPages) {
                        startPage = scope.pagination.totalPages - maxPages + 1;
                        endPage = scope.pagination.totalPages;
                    } else {
                        startPage = scope.pagination.currentPage - 2;
                        endPage = scope.pagination.currentPage + 2;
                    }
                }
                
                for (var i = startPage; i <= endPage; i++) {
                    pages.push(i);
                }
                
                scope.pageNumbers = pages;
            };
            
            scope.goToPage = function(page) {
                if (page < 1 || page > scope.pagination.totalPages || page === scope.pagination.currentPage) {
                    return;
                }
                scope.pagination.currentPage = page;
                scope.updatePageNumbers();
                scope.onPageChange();
            };
            
            scope.changePageSize = function() {
                scope.pagination.currentPage = 1;
                scope.updatePageNumbers();
                scope.onPageChange();
            };
            
            // Watch for changes
            scope.$watch('pagination.totalPages', function() {
                scope.updatePageNumbers();
            });
            
            scope.$watch('pagination.currentPage', function() {
                scope.updatePageNumbers();
            });
        }
    };
});

