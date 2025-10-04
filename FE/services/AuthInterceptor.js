angular.module("eduApp").factory("AuthInterceptor", function($q, $injector, $window) {
    return {
        // Trước khi gửi request → gắn accessToken vào header
        request: function(config) {
            var token = $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
            if (token) {
                config.headers.Authorization = "Bearer " + token;
            }
            return config;
        },

        // Nếu API trả về lỗi
        responseError: function(rejection) {
            var $http = $injector.get("$http"); 
            var AuthService = $injector.get("AuthService");
            var ToastService = $injector.get("ToastService"); // lấy toast qua injector
            var deferred = $q.defer();

            if (rejection.status === 401) {
                var msg = rejection.data && rejection.data.message ? rejection.data.message : "";

                // 🟢 Sai tài khoản/mật khẩu → reject luôn
                if (msg.includes("Sai tài khoản") || msg.includes("mật khẩu")) {
                    ToastService.show("Sai tài khoản hoặc mật khẩu", "error");
                    return $q.reject(rejection);
                }

                // 🟢 Token hết hạn → gọi refresh
                ToastService.show("Phiên đăng nhập đã hết hạn, đang thử làm mới token...", "warning");

                var refreshToken = $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");

                if (!refreshToken) {
                    ToastService.show("Không tìm thấy refresh token, vui lòng đăng nhập lại.", "error");
                    AuthService.logout();
                    window.location = "#!/login";
                    return $q.reject(rejection);
                }

                return AuthService.refresh(refreshToken)
                    .then(function(res) {
                        var newToken = res.data.token;
                        var newRefreshToken = res.data.refreshToken;

                        // ✅ Lưu token mới
                        $window.localStorage.setItem("token", newToken);
                        $window.localStorage.setItem("refreshToken", newRefreshToken);

                        // ✅ Retry request gốc
                        rejection.config.headers.Authorization = "Bearer " + newToken;
                        return $http(rejection.config); // ⚠️ return promise
                    })
                    .catch(function() {
                        // ❌ Refresh thất bại → logout
                        ToastService.show("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", "error");
                        AuthService.logout();
                        window.location = "#!/login";
                        return $q.reject(rejection);
                    });
            }

            // Các lỗi khác
            if (rejection.status >= 500) {
                ToastService.show("Lỗi máy chủ (" + rejection.status + ")", "error");
            }

            return $q.reject(rejection);
        }
    };
});
