angular.module("eduApp")

/* ============================================================
   🔹 AUTH INTERCEPTOR – Gắn token & tự refresh khi hết hạn
============================================================ */
.config(function ($httpProvider) {
    $httpProvider.interceptors.push(function ($q, $injector, $window) {
        let isRefreshing = false;
        let retryQueue = [];

        return {
            /* --- Gắn token vào mỗi request --- */
            request: function (config) {
                const AuthService = $injector.get("AuthService");
                const token = AuthService.getToken();
                if (token && config.url.startsWith("http")) {
                    config.headers = config.headers || {};
                    config.headers["Authorization"] = "Bearer " + token;
                }
                return config;
            },

            /* --- Xử lý lỗi --- */
            responseError: function (rejection) {
                const AuthService = $injector.get("AuthService");
                const $http = $injector.get("$http");

                // 🧩 Token hết hạn
                if (rejection.status === 401) {
                    const refreshToken = AuthService.getRefreshToken();

                    if (!refreshToken) {
                        AuthService.logout();
                        return $q.reject(rejection);
                    }

                    // Nếu đang refresh → chờ
                    if (isRefreshing) {
                        const deferred = $q.defer();
                        retryQueue.push({ config: rejection.config, deferred });
                        return deferred.promise;
                    }

                    isRefreshing = true;
                    return AuthService.refresh()
                        .then(res => {
                            const newToken = res.token;
                            const storage = $window.localStorage.getItem("token")
                                ? $window.localStorage
                                : $window.sessionStorage;
                            storage.setItem("token", newToken);

                            // Retry các request chờ
                            retryQueue.forEach(item => {
                                item.config.headers.Authorization = "Bearer " + newToken;
                                item.deferred.resolve($http(item.config));
                            });
                            retryQueue = [];

                            // Retry request gốc
                            rejection.config.headers.Authorization = "Bearer " + newToken;
                            return $http(rejection.config);
                        })
                        .catch(err => {
                            console.error("❌ Refresh thất bại:", err);
                            AuthService.logout();
                            return $q.reject(rejection);
                        })
                        .finally(() => {
                            isRefreshing = false;
                        });
                }

                // ⚠️ Lỗi khác
                if (rejection.status >= 500) {
                    console.error("Lỗi máy chủ:", rejection);
                }

                return $q.reject(rejection);
            }
        };
    });
});
