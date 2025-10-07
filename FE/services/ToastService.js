angular.module("eduApp").factory("ToastService", function($rootScope, $timeout) {
    $rootScope.toasts = $rootScope.toasts || [];

    function removeToast(toast) {
        toast.closing = true;
        $timeout(function() {
            var idx = $rootScope.toasts.findIndex(t => t.id === toast.id);
            if (idx >= 0) {
                $rootScope.toasts.splice(idx, 1);
            }
        }, 500);
    }

    return {
        show: function(message, type = "info", duration = 4000) {
            // 🔹 Giới hạn tối đa 3 toast
            if ($rootScope.toasts.length >= 3) {
                // Xóa toast cũ nhất
                removeToast($rootScope.toasts[0]);
            }

            var toast = { 
                id: Date.now(), 
                message: message, 
                type: type,
                closing: false
            };
            
            $rootScope.toasts.push(toast);

            $timeout(function() {
                removeToast(toast);
            }, duration);
        },

        remove: removeToast,

        clearAll: function() {
            $rootScope.toasts = [];
        }
    };
});
