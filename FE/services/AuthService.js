angular.module("eduApp")

/* ============================================================
   🔹 AUTH SERVICE – Quản lý đăng nhập, token, refresh, logout, user info & menu
============================================================ */
.factory("AuthService", function ($http, $window, $q, $rootScope) {
    const gatewayBase = "https://localhost:7033";
    const apiAuth = gatewayBase + "/api-edu/auth";
    const apiMenu = gatewayBase + "/api-edu/admin/menu";

    const auth = {};

    /* ============================================================
       🧩 Helpers
    ============================================================ */
    function getStorage() {
        return $window.localStorage.getItem("token")
            ? $window.localStorage
            : $window.sessionStorage;
    }

    function clearAllStorage() {
        $window.localStorage.clear();
        $window.sessionStorage.clear();
    }

    /* ============================================================
       🔐 LOGIN
    ============================================================ */
    auth.login = function (username, password, rememberMe) {
        return $http.post(apiAuth + "/login", { username, password }, {
            headers: { "Content-Type": "application/json" }
        })
        .then(function (res) {
            const data = res.data;
            if (data && data.token) {
                const storage = rememberMe ? $window.localStorage : $window.sessionStorage;
                storage.setItem("token", data.token);
                storage.setItem("refreshToken", data.refreshToken);
                storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                let avatarUrl = data.avatarUrl;
                if (avatarUrl && avatarUrl.startsWith("/uploads"))
                    avatarUrl = gatewayBase + avatarUrl;

                const user = {
                    userId: data.userId,
                    username: data.username,
                    fullName: data.fullName,
                    email: data.email,
                    role: data.role,
                    avatarUrl: avatarUrl || null
                };
                storage.setItem("currentUser", JSON.stringify(user));

                $rootScope.isAuthenticated = true;
                $rootScope.$broadcast("auth:login", user);
            }
            return data;
        })
        .catch(err => {
            console.error("❌ Login failed:", err);
            return $q.reject(err);
        });
    };

    /* ============================================================
       🔁 REFRESH TOKEN
    ============================================================ */
    auth.refresh = function () {
        const refreshToken = auth.getRefreshToken();
        if (!refreshToken) return $q.reject("No refresh token");

        return $http.post(apiAuth + "/refresh", { refreshToken })
            .then(function (res) {
                const data = res.data;
                if (data && data.token) {
                    const storage = $window.localStorage.getItem("token")
                        ? $window.localStorage
                        : $window.sessionStorage;

                    storage.setItem("token", data.token);
                    if (data.refreshToken) storage.setItem("refreshToken", data.refreshToken);
                    if (data.refreshTokenExpiry) storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                    $rootScope.isAuthenticated = true;
                    return data;
                } else {
                    return $q.reject("Invalid refresh response");
                }
            })
            .catch(err => {
                console.error("❌ Refresh token failed:", err);
                return $q.reject(err);
            });
    };

    /* ============================================================
       🚪 LOGOUT
    ============================================================ */
    auth.logout = function () {
        const refreshToken = auth.getRefreshToken();
        const token = auth.getToken();
        const config = token ? { headers: { Authorization: "Bearer " + token } } : {};

        if (refreshToken && token) {
            return $http.post(apiAuth + "/logout", { refreshToken }, config)
                .catch(err => console.error("Logout API failed:", err))
                .finally(() => {
                    clearAllStorage();
                    $rootScope.isAuthenticated = false;
                    $rootScope.$broadcast("auth:logout");
                    $window.location.href = "#/login";
                });
        } else {
            clearAllStorage();
            $rootScope.isAuthenticated = false;
            $rootScope.$broadcast("auth:logout");
            $window.location.href = "#/login";
            return $q.resolve();
        }
    };

    /* ============================================================
       ⚙️ TOKEN & USER HELPERS
    ============================================================ */
    auth.getToken = () => $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
    auth.getRefreshToken = () => $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");
    auth.isAuthenticated = () => !!auth.getToken();

    // 🔹 Lấy thông tin user
    auth.getUser = function () {
        const raw = getStorage().getItem("currentUser");
        try { return JSON.parse(raw); } catch { return null; }
    };

    // 🔹 Ghi lại thông tin user (sau khi cập nhật hồ sơ)
    auth.setUser = function (user) {
        const storage = getStorage();
        storage.setItem("currentUser", JSON.stringify(user));
        $rootScope.$broadcast("auth:userUpdated", user);
    };

    // 🔹 Lấy các field cơ bản
    auth.getFullName = function () {
        const user = auth.getUser();
        return user ? user.fullName : null;
    };

    auth.getRole = function () {
        const user = auth.getUser();
        return user ? user.role : null;
    };

    auth.getAvatarUrl = function () {
        const user = auth.getUser();
        return user ? user.avatarUrl : null;
    };

    auth.getAuthHeader = () => {
        const t = auth.getToken();
        return t ? { Authorization: "Bearer " + t } : {};
    };

    /* ============================================================
       📚 LẤY DANH SÁCH MENU (theo vai trò người dùng)
    ============================================================ */
    auth.getMenus = function() {
        return $http.get(apiMenu, { headers: auth.getAuthHeader() })
            .then(function(res) {
                // Một số BE có thể trả { data: [...] }
                if (Array.isArray(res.data)) {
                    return res.data;
                } else if (Array.isArray(res.data.data)) {
                    return res.data.data;
                } else if (Array.isArray(res.data.menus)) {
                    return res.data.menus;
                } else {
                    console.warn("⚠️ Menu API không trả về dạng mảng:", res.data);
                    return [];
                }
            })
            .catch(function(err) {
                console.error("❌ Lỗi khi lấy menu:", err);
                return $q.reject(err);
            });
    };

    return auth;
});
