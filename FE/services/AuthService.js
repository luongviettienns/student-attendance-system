angular.module("eduApp")

/* ============================================================
   🔹 AUTH SERVICE – Quản lý đăng nhập, token, refresh, logout, user info & menu
============================================================ */
.factory("AuthService", function ($http, $window, $q, $rootScope) {

    /* ============================================================
       ⚙️ BASE CONFIG
    ============================================================ */
    const BASE_URL = "https://localhost:7033/api-edu"; // ✅ Gateway URL
    const apiAuth = BASE_URL + "/auth";
    const apiMenu = BASE_URL + "/admin/menu";

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
            const data = res.data?.data || res.data; // Một số API trả {data: {...}}

            if (data && data.token) {
                const storage = rememberMe ? $window.localStorage : $window.sessionStorage;
                storage.setItem("token", data.token);
                storage.setItem("refreshToken", data.refreshToken);
                storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                // ✅ Chuẩn hóa avatarUrl
                let avatarUrl = data.avatarUrl;

                // Nếu BE trả tương đối (/avatars/user-001.png) → ghép vào host Gateway
                if (avatarUrl && avatarUrl.startsWith("/avatars")) {
                    const gatewayOrigin = BASE_URL.replace("/api-edu", "");
                    avatarUrl = gatewayOrigin + avatarUrl;
                }

                // Nếu BE không có avatar → dùng ảnh mặc định
                if (!avatarUrl || avatarUrl.trim() === "") {
                    avatarUrl = BASE_URL.replace("/api-edu", "") + "/avatars/default.png";
                }

                const user = {
                    userId: data.userId,
                    username: data.username,
                    fullName: data.fullName,
                    email: data.email,
                    role: data.role,
                    avatarUrl: avatarUrl
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
                clearAllStorage();
                $rootScope.isAuthenticated = false;
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

        const doClear = () => {
            clearAllStorage();
            $rootScope.isAuthenticated = false;
            $rootScope.$broadcast("auth:logout");
            sessionStorage.setItem("justLoggedOut", "true");
            $window.location.href = "#/login";
        };

        if (refreshToken && token) {
            return $http.post(apiAuth + "/logout", { refreshToken }, config)
                .catch(err => console.error("Logout API failed:", err))
                .finally(doClear);
        } else {
            doClear();
            return $q.resolve();
        }
    };

    /* ============================================================
       ⚙️ TOKEN & USER HELPERS
    ============================================================ */
    auth.getToken = () =>
        $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");

    auth.getRefreshToken = () =>
        $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");

    auth.isAuthenticated = () => !!auth.getToken();

    auth.getUser = function () {
        const raw = getStorage().getItem("currentUser");
        try { return JSON.parse(raw); } catch { return null; }
    };

    auth.setUser = function (user) {
        const storage = getStorage();
        storage.setItem("currentUser", JSON.stringify(user));
        $rootScope.$broadcast("auth:userUpdated", user);
    };

    auth.getFullName = () => (auth.getUser()?.fullName ?? null);
    auth.getRole = () => (auth.getUser()?.role ?? null);
    auth.getAvatarUrl = () => (auth.getUser()?.avatarUrl ?? null);

    auth.getAuthHeader = () => {
        const t = auth.getToken();
        return t ? { Authorization: "Bearer " + t } : {};
    };

    /* ============================================================
       📚 LẤY MENU THEO VAI TRÒ
    ============================================================ */
    auth.getMenus = function() {
        return $http.get(apiMenu, { headers: auth.getAuthHeader() })
            .then(function(res) {
                if (Array.isArray(res.data)) return res.data;
                if (Array.isArray(res.data.data)) return res.data.data;
                if (Array.isArray(res.data.menus)) return res.data.menus;
                console.warn("⚠️ Menu API không trả về dạng mảng:", res.data);
                return [];
            })
            .catch(function(err) {
                console.error("❌ Lỗi khi lấy menu:", err);
                return $q.reject(err);
            });
    };

    /* ============================================================
       🚦 HỖ TRỢ: Redirect sau đăng nhập
    ============================================================ */
    auth.redirectAfterLogin = function(role) {
        // Có thể tùy chỉnh theo vai trò sau này
        return "main.welcome";
    };

    return auth;
});
