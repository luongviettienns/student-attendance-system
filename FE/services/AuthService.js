angular.module("eduApp")

.factory("AuthService", function ($http, $window, $q, $rootScope) {

    // ============================================================
    // ⚙️ BASE CONFIG
    // ============================================================
    const BASE_URL = "https://localhost:7033/api-edu";
    const apiAuth  = `${BASE_URL}/auth`;
    const apiMenu  = `${BASE_URL}/menu`;

    const auth = {};

    // ============================================================
    // 🧩 Helpers
    // ============================================================
    const getStorage = () =>
        $window.localStorage.getItem("token") ? $window.localStorage : $window.sessionStorage;

    const clearStorage = () => {
        $window.localStorage.clear();
        $window.sessionStorage.clear();
    };

    const setItem = (key, val) => getStorage().setItem(key, val);
    const getItem = key => getStorage().getItem(key);

    // ============================================================
    // 🔐 LOGIN
    // ============================================================
    auth.login = (username, password, rememberMe) =>
        $http.post(`${apiAuth}/login`, { username, password }, {
            headers: { "Content-Type": "application/json" }
        })
        .then(res => {
            const data = res.data?.data || res.data;
            if (!data?.token) return $q.reject({ message: "Phản hồi không hợp lệ từ máy chủ" });

            // ✅ Lưu token
            const storage = rememberMe ? $window.localStorage : $window.sessionStorage;
            storage.setItem("token", data.token);
            if (data.refreshToken) storage.setItem("refreshToken", data.refreshToken);
            if (data.refreshTokenExpiry) storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

            // ✅ Đặt header mặc định
            $http.defaults.headers.common["Authorization"] = `Bearer ${data.token}`;

            // ✅ Avatar fallback
            let avatarUrl = data.avatarUrl;
            if (!avatarUrl || !avatarUrl.trim()) {
                const gatewayOrigin = BASE_URL.replace("/api-edu", "");
                avatarUrl = `${gatewayOrigin}/avatars/default.png`;
            }

            // ✅ Lưu thông tin user
            const user = {
                userId: data.userId,
                username: data.username,
                fullName: data.fullName,
                email: data.email,
                role: data.role,
                avatarUrl
            };

            storage.setItem("currentUser", JSON.stringify(user));

            // ✅ Cập nhật trạng thái
            $rootScope.isAuthenticated = true;
            $rootScope.$broadcast("auth:login", user);

            return data;
        })
        .catch(err => {
            console.error("❌ Login failed:", err);

            let message = "Đăng nhập thất bại";

            // ✅ Trường hợp không kết nối được tới API Gateway
            if (err.status === -1 || err.xhrStatus === "error") {
                message = "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại API Gateway.";
            }
            // ✅ Trường hợp BE phản hồi lỗi hợp lệ
            else if (err.data?.message) {
                message = err.data.message;
            }
            // ✅ Mặc định fallback
            else {
                message = "Sai tài khoản hoặc mật khẩu";
            }

            return $q.reject({ message });
        });

    // ============================================================
    // 🔁 REFRESH TOKEN
    // ============================================================
    auth.refresh = () => {
        const refreshToken = auth.getRefreshToken();
        if (!refreshToken) return $q.reject("Không có refresh token");

        return $http.post(`${apiAuth}/refresh`, { refreshToken })
            .then(res => {
                const data = res.data?.data || res.data;
                if (!data?.token) return $q.reject("Phản hồi refresh không hợp lệ");

                const storage = getStorage();
                setItem("token", data.token);
                if (data.refreshToken) setItem("refreshToken", data.refreshToken);
                if (data.refreshTokenExpiry) setItem("refreshTokenExpiry", data.refreshTokenExpiry);

                // 🟢 Gắn lại token global
                $http.defaults.headers.common["Authorization"] = `Bearer ${data.token}`;

                $rootScope.isAuthenticated = true;
                return data;
            })
            .catch(err => {
                console.error("❌ Refresh token failed:", err);
                clearStorage();
                $rootScope.isAuthenticated = false;
                return $q.reject(err);
            });
    };

    // ============================================================
    // 🚪 LOGOUT
    // ============================================================
    auth.logout = () => {
        const refreshToken = auth.getRefreshToken();
        const token = auth.getToken();
        const headers = token ? { Authorization: "Bearer " + token } : {};

        const clearAndRedirect = () => {
            clearStorage();
            delete $http.defaults.headers.common["Authorization"];
            $rootScope.isAuthenticated = false;
            $rootScope.$broadcast("auth:logout");
            setTimeout(() => { $window.location.href = "#/login"; }, 200);
        };

        if (refreshToken && token) {
            return $http.post(`${apiAuth}/logout`, { refreshToken }, { headers })
                .finally(clearAndRedirect);
        } else {
            clearAndRedirect();
            return $q.resolve();
        }
    };

    // ============================================================
    // ⚙️ TOKEN & USER HELPERS
    // ============================================================
    auth.getToken = () =>
        $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");

    auth.getRefreshToken = () =>
        $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");

    auth.isAuthenticated = () => !!auth.getToken();

    auth.getUser = () => {
        try { return JSON.parse(getItem("currentUser")); }
        catch { return null; }
    };

    auth.setUser = user => {
        setItem("currentUser", JSON.stringify(user));
        $rootScope.$broadcast("auth:userUpdated", user);
    };

    auth.getAuthHeader = () => {
        const t = auth.getToken();
        return t ? { Authorization: "Bearer " + t } : {};
    };

    // ============================================================
    // 📚 LẤY MENU THEO ROLE
    // ============================================================
    auth.getMenus = () =>
        $http.get(apiMenu, { headers: auth.getAuthHeader() })
            .then(res => {
                const d = res.data;
                if (Array.isArray(d)) return d;
                if (Array.isArray(d.data)) return d.data;
                if (Array.isArray(d.menus)) return d.menus;
                console.warn("⚠️ API menu trả dữ liệu không hợp lệ:", d);
                return [];
            })
            .catch(err => {
                console.error("❌ Lỗi khi tải menu:", err);
                return $q.reject(err);
            });

    // ============================================================
    // 🚦 REDIRECT SAU LOGIN
    // ============================================================
    auth.redirectAfterLogin = role => {
        role = (role || "").toLowerCase();
        switch (role) {
            case "admin":
                return "main.welcome"; // ✅ sửa lại đúng state dashboard cha
            case "lecturer":
                return "main.teacher.classView";
            case "student":
                return "main.student.scheduleView";
            default:
                return "main.welcome";
        }
    };

    return auth;
});
