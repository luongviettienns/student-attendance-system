angular.module("eduApp")

/* ============================================================
   🔹 AUTH INTERCEPTOR – Gắn token & tự refresh khi hết hạn
============================================================ */
.config(function ($httpProvider) {
    $httpProvider.interceptors.push(function ($q, $injector, $window) {
        let isRefreshing = false;
        let retryQueue = [];

        return {
            /* ============================================================
               🔹 Gắn token vào mỗi request
            ============================================================ */
            request: function (config) {
                const AuthService = $injector.get("AuthService");
                const token = AuthService.getToken();

                // ✅ Chỉ gắn token cho request nội bộ (qua Gateway)
                if (token && config.url.startsWith("https://localhost:7033")) {
                    config.headers = config.headers || {};
                    config.headers["Authorization"] = "Bearer " + token;
                }

                return config;
            },

            /* ============================================================
               🔹 Xử lý lỗi response
            ============================================================ */
            responseError: function (rejection) {
                const AuthService = $injector.get("AuthService");
                const $http = $injector.get("$http");

                // 🧩 Token hết hạn → tự refresh
                if (rejection.status === 401) {
                    const refreshToken = AuthService.getRefreshToken();

                    // Không có refresh token → logout luôn
                    if (!refreshToken) {
                        AuthService.logout();
                        return $q.reject(rejection);
                    }

                    // Nếu đang refresh → chờ đợi
                    if (isRefreshing) {
                        const deferred = $q.defer();
                        retryQueue.push({ config: rejection.config, deferred });
                        return deferred.promise;
                    }

                    // Bắt đầu refresh token
                    isRefreshing = true;
                    return AuthService.refresh()
                        .then(res => {
                            const newToken = res.token;
                            const storage = $window.localStorage.getItem("token")
                                ? $window.localStorage
                                : $window.sessionStorage;
                            storage.setItem("token", newToken);

                            // Retry các request trong hàng đợi
                            retryQueue.forEach(item => {
                                item.config.headers.Authorization = "Bearer " + newToken;
                                item.deferred.resolve($http(item.config));
                            });
                            retryQueue = [];

                            // Retry lại request gốc
                            rejection.config.headers.Authorization = "Bearer " + newToken;
                            return $http(rejection.config);
                        })
                        .catch(err => {
                            console.error("❌ Refresh token thất bại:", err);
                            AuthService.logout();
                            return $q.reject(rejection);
                        })
                        .finally(() => {
                            isRefreshing = false;
                        });
                }

                // ⚠️ Lỗi khác (500, 404, 403, ...)
                if (rejection.status === 404) {
                    console.warn("⚠️ API không tồn tại:", rejection.config.url);
                } else if (rejection.status >= 500) {
                    console.error("💥 Lỗi máy chủ:", rejection);
                }

                return $q.reject(rejection);
            }
        };
    });
});
