angular.module("eduApp").factory("ToastService", function($rootScope, $timeout) {
    $rootScope.toasts = $rootScope.toasts || [];

    function removeToast(toast) {
        toast.closing = true; // bật cờ fadeOut
        $timeout(function() {
            var idx = $rootScope.toasts.findIndex(t => t.id === toast.id);
            if (idx >= 0) {
                $rootScope.toasts.splice(idx, 1);
            }
        }, 500); // chờ hết animation fadeOut
    }

    return {
        show: function(message, type = "info", duration = 4000) {
            var toast = { 
                id: Date.now(), 
                message: message, 
                type: type,
                closing: false
            };
            
            $rootScope.toasts.push(toast);

            // Auto close
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
