angular.module("eduApp").factory("AuthService", function($http, $window, $q) {
    var auth = {};
    var apiUrl = "http://localhost:5090/api-edu/auth";   
    // Nếu gateway chạy HTTPS thì đổi:
    // var apiUrl = "https://localhost:7033/api-edu/auth";

    // Helper: chọn storage (ưu tiên localStorage nếu có token)
    function getStorage() {
        return $window.localStorage.getItem("token")
            ? $window.localStorage
            : $window.sessionStorage;
    }

    // 🔹 Đăng nhập
    auth.login = function(username, password, rememberMe) {
        return $http.post(apiUrl + "/login",
            { username: username, password: password },
            { headers: { "Content-Type": "application/json" } }
        )
        .then(function(response) {
            var data = response.data;

            if (data && data.token) {
                var storage = rememberMe ? $window.localStorage : $window.sessionStorage;

                // Lưu token & refreshToken
                storage.setItem("token", data.token);
                storage.setItem("refreshToken", data.refreshToken);
                storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                // 🔹 Lưu thông tin user thành object duy nhất
                var user = {
                    userId: data.userId,
                    username: data.username,
                    fullName: data.fullName,
                    email: data.email,
                    role: data.role,
                    avatarUrl: data.avatarUrl || "assets/img/default-avatar.png"
                };
                storage.setItem("currentUser", JSON.stringify(user));
            }

            return data;
        })
        .catch(function(error) {
            console.error("Login failed:", error);
            return $q.reject(error);
        });
    };

    // 🔹 Làm mới token
    auth.refresh = function() {
        var refreshToken = auth.getRefreshToken();
        if (!refreshToken) {
            return $q.reject("No refresh token");
        }

        return $http.post(apiUrl + "/refresh", { refreshToken: refreshToken })
            .then(function(response) {
                var data = response.data;
                var storage = getStorage();

                storage.setItem("token", data.token);
                storage.setItem("refreshToken", data.refreshToken);
                storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                return data;
            })
            .catch(function(err) {
                console.error("Refresh failed:", err);
                auth.logout();
                return $q.reject(err);
            });
    };

    // 🔹 Đăng xuất
    auth.logout = function() {
        var refreshToken = auth.getRefreshToken();
        var token = auth.getToken();
        var config = token ? { headers: { Authorization: "Bearer " + token } } : {};

        if (refreshToken) {
            return $http.post(apiUrl + "/logout", { refreshToken: refreshToken }, config)
                .finally(function() {
                    $window.localStorage.clear();
                    $window.sessionStorage.clear();
                });
        } else {
            $window.localStorage.clear();
            $window.sessionStorage.clear();
            return $q.resolve();
        }
    };

    // 🔹 Token helpers
    auth.getToken = function() {
        return $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
    };
    auth.getRefreshToken = function() {
        return $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");
    };

    // 🔹 Check refreshToken expiry
    auth.isRefreshTokenValid = function() {
        var expiry = getStorage().getItem("refreshTokenExpiry");
        if (!expiry) return false;
        return new Date(expiry) > new Date();
    };

    // 🔹 Lấy user hiện tại
    auth.getUser = function() {
        var storage = getStorage();
        var raw = storage.getItem("currentUser");

        if (!raw) {
            return {
                userId: null,
                username: null,
                fullName: "Người dùng",
                email: null,
                role: "Unknown",
                avatarUrl: "assets/img/default-avatar.png"
            };
        }

        try {
            return JSON.parse(raw);
        } catch {
            return {
                userId: null,
                username: null,
                fullName: "Người dùng",
                email: null,
                role: "Unknown",
                avatarUrl: "assets/img/default-avatar.png"
            };
        }
    };

    // 🔹 Cập nhật lại user trong storage (ví dụ khi update profile)
    auth.setUser = function(user) {
        var storage = getStorage();
        storage.setItem("currentUser", JSON.stringify(user));
    };

    // Shortcut
    auth.getUserId = function() { return auth.getUser().userId; };
    auth.getUsername = function() { return auth.getUser().username; };
    auth.getFullName = function() { return auth.getUser().fullName; };
    auth.getRole = function() { return auth.getUser().role; };
    auth.getAvatarUrl = function() { return auth.getUser().avatarUrl; };

    // 🔹 Check login
    auth.isAuthenticated = function() {
        return !!auth.getToken();
    };

    return auth;
});
