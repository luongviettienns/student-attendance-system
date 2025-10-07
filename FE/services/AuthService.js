angular.module("eduApp").factory("AuthService", function($http, $window, $q, $rootScope) {
    const apiUrl = "http://localhost:5090/api-edu/auth";   
    // Nếu gateway chạy HTTPS:
    // const apiUrl = "https://localhost:7033/api-edu/auth";

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
    auth.login = function(username, password, rememberMe) {
  return $http.post(apiUrl + "/login", 
      { username, password }, 
      { headers: { "Content-Type": "application/json" } }
  )
  .then(function(response) {
      const data = response.data;
      if (data && data.token) {
          const storage = rememberMe ? $window.localStorage : $window.sessionStorage;

          // Lưu token và refresh token
          storage.setItem("token", data.token);
          storage.setItem("refreshToken", data.refreshToken);
          storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);

          // ✅ Xử lý avatar URL tuyệt đối
          let avatarUrl = data.avatarUrl;
          if (!avatarUrl) {
              avatarUrl = "assets/img/default-avatar.png";
          } 
          else if (avatarUrl.startsWith("/uploads")) {
              // BE trả tương đối (phòng trường hợp server staging)
              avatarUrl = "https://localhost:7051" + avatarUrl;
          }

          // Lưu thông tin người dùng
          const user = {
              userId: data.userId,
              username: data.username,
              fullName: data.fullName,
              email: data.email,
              role: data.role,
              avatarUrl: avatarUrl   // ✅ đảm bảo luôn có URL tuyệt đối
          };

          storage.setItem("currentUser", JSON.stringify(user));
          $rootScope.isAuthenticated = true;
      }
      return data;
  })
  .catch(function(err) {
      console.error("❌ Login failed:", err);
      return $q.reject(err);
  });
};


    /* ============================================================
       🔁 REFRESH TOKEN
    ============================================================ */
    auth.refresh = function() {
        const refreshToken = auth.getRefreshToken();
        if (!refreshToken) {
            return $q.reject("No refresh token");
        }

        return $http.post(apiUrl + "/refresh", { refreshToken })
            .then(function(response) {
                const data = response.data;
                const storage = getStorage();

                storage.setItem("token", data.token);
                storage.setItem("refreshToken", data.refreshToken);
                storage.setItem("refreshTokenExpiry", data.refreshTokenExpiry);
                return data;
            })
            .catch(function(err) {
                console.warn("⚠️ Refresh token failed, logging out.");
                auth.logout();
                return $q.reject(err);
            });
    };

    /* ============================================================
       🚪 LOGOUT
    ============================================================ */
    auth.logout = function() {
        const refreshToken = auth.getRefreshToken();
        const token = auth.getToken();
        const config = token ? { headers: { Authorization: "Bearer " + token } } : {};

        if (refreshToken && token) {
            return $http.post(apiUrl + "/logout", { refreshToken }, config)
                .catch(function(error) {
                    if (error.status === 401) {
                        console.warn("⚠️ Token expired, skip logout API.");
                    } else {
                        console.error("Logout API failed:", error);
                    }
                })
                .finally(function() {
                    clearAllStorage();
                    $rootScope.isAuthenticated = false;
                });
        } else {
            clearAllStorage();
            $rootScope.isAuthenticated = false;
            return $q.resolve();
        }
    };

    /* ============================================================
       🪪 TOKEN HELPERS
    ============================================================ */
    auth.getToken = function() {
        return $window.localStorage.getItem("token") || $window.sessionStorage.getItem("token");
    };

    auth.getRefreshToken = function() {
        return $window.localStorage.getItem("refreshToken") || $window.sessionStorage.getItem("refreshToken");
    };

    auth.isRefreshTokenValid = function() {
        const expiry = getStorage().getItem("refreshTokenExpiry");
        if (!expiry) return false;
        return new Date(expiry) > new Date();
    };

    /* ============================================================
       👤 USER HELPERS
    ============================================================ */
    auth.getUser = function() {
        const storage = getStorage();
        const raw = storage.getItem("currentUser");
        if (!raw) return null;
        try {
            return JSON.parse(raw);
        } catch {
            return null;
        }
    };

    auth.setUser = function(user) {
        const storage = getStorage();
        storage.setItem("currentUser", JSON.stringify(user));
    };

    auth.getUserId = function() {
        const u = auth.getUser();
        return u ? u.userId : null;
    };

    auth.getFullName = function() {
        const u = auth.getUser();
        return u ? u.fullName : "Người dùng";
    };

    auth.getRole = function() {
        const u = auth.getUser();
        return u ? u.role : "Unknown";
    };

    auth.getAvatarUrl = function() {
        const u = auth.getUser();
        return u ? u.avatarUrl : "assets/img/default-avatar.png";
    };

    /* ============================================================
       🧠 STATUS
    ============================================================ */
    auth.isAuthenticated = function() {
        return !!auth.getToken();
    };

    return auth;
});
