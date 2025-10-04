angular.module("eduApp").factory("ToastService", function($rootScope, $timeout) {
    $rootScope.toasts = $rootScope.toasts || [];

    function removeToast(toast) {
        toast.closing = true; // bật cờ fadeOut để CSS chạy animation
        $timeout(function() {
            var idx = $rootScope.toasts.findIndex(t => t.id === toast.id);
            if (idx >= 0) {
                $rootScope.toasts.splice(idx, 1);
            }
        }, 500); // chờ hết animation fadeOut (0.5s trong CSS)
    }

    return {
        /**
         * Hiển thị toast mới
         * @param {string} message - Nội dung hiển thị
         * @param {string} type - Loại: success | error | warning | info
         * @param {number} duration - Thời gian hiển thị (ms)
         */
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

        /** Đóng 1 toast */
        remove: removeToast,

        /** Xóa tất cả toast */
        clearAll: function() {
            $rootScope.toasts = [];
        }
    };
});
