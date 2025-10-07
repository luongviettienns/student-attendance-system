angular.module("eduApp").factory("AuthInterceptor", function($q, $injector, $window, $rootScope) {
    let isRefreshing = false; // tránh gọi refresh nhiều lần cùng lúc
    let retryQueue = [];      // lưu tạm các request bị 401 trong lúc refresh

    return {
        /* ============================================================
           🧩 REQUEST: Gắn token vào tất cả request ra ngoài
        ============================================================ */
        request: function(config) {
            const token = $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
            if (token) {
                config.headers.Authorization = "Bearer " + token;
            }
            return config;
        },

        /* ============================================================
           ⚠️ RESPONSE ERROR: Xử lý lỗi 401, 500,...
        ============================================================ */
        responseError: function(rejection) {
            const AuthService = $injector.get("AuthService");
            const ToastService = $injector.get("ToastService");
            const $http = $injector.get("$http");

            // Nếu token hết hạn hoặc không hợp lệ
            if (rejection.status === 401) {
                const message = (rejection.data && rejection.data.message) || "";

                // 1️⃣ Sai tài khoản/mật khẩu → reject luôn
                if (message.includes("Sai tài khoản") || message.includes("mật khẩu")) {
                    ToastService.show("Sai tài khoản hoặc mật khẩu", "error");
                    return $q.reject(rejection);
                }

                // 2️⃣ Token hết hạn → xử lý refresh
                const refreshToken = AuthService.getRefreshToken();
                if (!refreshToken) {
                    ToastService.show("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", "error");
                    AuthService.logout().finally(() => {
                        window.location = "#!/login";
                    });
                    return $q.reject(rejection);
                }

                // Nếu đang refresh token → đẩy request vào hàng đợi
                if (isRefreshing) {
                    const deferred = $q.defer();
                    retryQueue.push({ config: rejection.config, deferred });
                    return deferred.promise;
                }

                isRefreshing = true;
                ToastService.show("Đang làm mới phiên đăng nhập...", "info");

                // Gọi refresh token
                return AuthService.refresh()
                    .then(function(res) {
                        const newToken = res.token;
                        const storage = $window.localStorage.getItem("token")
                            ? $window.localStorage
                            : $window.sessionStorage;
                        storage.setItem("token", newToken);

                        // ✅ Retry lại các request đang chờ
                        retryQueue.forEach(item => {
                            item.config.headers.Authorization = "Bearer " + newToken;
                            item.deferred.resolve($http(item.config));
                        });
                        retryQueue = [];

                        // ✅ Retry request gốc
                        rejection.config.headers.Authorization = "Bearer " + newToken;
                        return $http(rejection.config);
                    })
                    .catch(function() {
                        ToastService.show("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", "error");
                        AuthService.logout().finally(() => {
                            window.location = "#!/login";
                        });
                        return $q.reject(rejection);
                    })
                    .finally(function() {
                        isRefreshing = false;
                    });
            }

            // 3️⃣ Các lỗi khác
            if (rejection.status >= 500) {
                ToastService.show("Lỗi máy chủ (" + rejection.status + ")", "error");
            }

            return $q.reject(rejection);
        }
    };
});
