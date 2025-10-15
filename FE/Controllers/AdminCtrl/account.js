angular.module("eduApp").controller("AccountController", function ($scope, $http, $timeout, AuthService) {
  const gatewayBase = "http://localhost:5090";
  const apiAdmin = gatewayBase + "/api-edu/admin";

  /* ============================================================
     🔹 STATE
  ============================================================ */
  $scope.users = [];
  $scope.roles = [];
  $scope.loading = false;

  $scope.showModal = false;
  $scope.isEdit = false;
  $scope.formData = {};

  $scope.pagination = {
    page: 1,
    pageSize: 10,
    totalPages: 1,
    totalCount: 0
  };

  // 🔹 Thống kê người dùng (hiển thị ở summary cards)
  $scope.totalUsers = 0;
  $scope.activeUsers = 0;
  $scope.inactiveUsers = 0;

  /* ============================================================
     🔹 LOAD DANH SÁCH NGƯỜI DÙNG
  ============================================================ */
  $scope.loadUsers = function () {
    $scope.loading = true;
    $scope.users = [];

    const params = {
      page: $scope.pagination.page,
      pageSize: $scope.pagination.pageSize,
      search: $scope.searchText || null,
      roleId: $scope.filterRoleId || null,
      isActive: $scope.filterStatus !== "" ? $scope.filterStatus : null
    };

    $http
      .get(apiAdmin + "/users", {
        headers: AuthService.getAuthHeader(),
        params
      })
      .then(res => {
        $scope.users = res.data.data || [];
        $scope.pagination = res.data.pagination || $scope.pagination;

        // ✅ Hiệu ứng fade-in từng dòng
        $timeout(() => {
          angular.element(".account-table tbody tr").each(function (i, el) {
            el.style.opacity = 0;
            el.style.transform = "translateY(10px)";
            setTimeout(() => {
              el.style.transition = "all 0.35s ease";
              el.style.opacity = 1;
              el.style.transform = "translateY(0)";
            }, i * 80);
          });
        }, 100);

        // ✅ Cập nhật thống kê (tự tính nếu chưa có API riêng)
        $scope.totalUsers = $scope.pagination.totalCount || $scope.users.length;
        $scope.activeUsers = $scope.users.filter(u => u.isActive).length;
        $scope.inactiveUsers = $scope.users.filter(u => !u.isActive).length;
      })
      .catch(err => {
        console.error("❌ Lỗi tải danh sách người dùng:", err);
        alert("Không thể tải danh sách người dùng");
      })
      .finally(() => {
        $scope.loading = false;
      });
  };

  /* ============================================================
     🔹 LOAD DANH SÁCH VAI TRÒ
  ============================================================ */
  $scope.loadRoles = function () {
    $http
      .get(apiAdmin + "/roles", { headers: AuthService.getAuthHeader() })
      .then(res => {
        $scope.roles = res.data.data || [];
      })
      .catch(err => console.error("❌ Lỗi tải danh sách vai trò:", err));
  };

  /* ============================================================
     🔹 BỘ LỌC & PHÂN TRANG
  ============================================================ */
  $scope.searchUsers = function () {
    $scope.pagination.page = 1;
    $scope.loadUsers();
  };

  $scope.changePage = function (page) {
    if (page < 1 || page > $scope.pagination.totalPages) return;
    $scope.pagination.page = page;
    $scope.loadUsers();
  };

  /* ============================================================
     🔹 MODAL: MỞ / ĐÓNG
  ============================================================ */
  $scope.openAddUser = function () {
    $scope.isEdit = false;
    $scope.formData = { isActive: "true" };
    $scope.showModal = true;
  };

  $scope.editUser = function (user) {
    $scope.isEdit = true;
    $scope.formData = angular.copy(user);
    $scope.formData.isActive = String(user.isActive);
    $scope.showModal = true;
  };

  $scope.closeModal = function () {
    $scope.showModal = false;
  };

  /* ============================================================
     🔹 LƯU (THÊM / CẬP NHẬT)
  ============================================================ */
  $scope.saveUser = function () {
    const data = angular.copy($scope.formData);
    data.isActive = data.isActive === "true";

    const request = $scope.isEdit
      ? $http.put(`${apiAdmin}/users/${data.userId}`, data, { headers: AuthService.getAuthHeader() })
      : $http.post(`${apiAdmin}/users`, data, { headers: AuthService.getAuthHeader() });

    request
      .then(res => {
        alert(res.data.message || ($scope.isEdit ? "Cập nhật thành công" : "Thêm mới thành công"));
        $scope.closeModal();
        $scope.loadUsers();
      })
      .catch(err => {
        console.error("❌ Lỗi lưu người dùng:", err);
        alert(err.data?.message || "Không thể lưu người dùng");
      });
  };

  /* ============================================================
     🔹 XOÁ NGƯỜI DÙNG (SOFT DELETE)
  ============================================================ */
  $scope.deleteUser = function (user) {
    if (!confirm(`Bạn có chắc muốn xoá người dùng "${user.username}" không?`)) return;

    $http
      .delete(`${apiAdmin}/users/${user.userId}`, { headers: AuthService.getAuthHeader() })
      .then(res => {
        alert(res.data.message || "Đã xoá người dùng");
        $scope.loadUsers();
      })
      .catch(err => {
        console.error("❌ Lỗi xoá người dùng:", err);
        alert(err.data?.message || "Không thể xoá người dùng");
      });
  };

  /* ============================================================
     🔹 KHỞI TẠO
  ============================================================ */
  $scope.loadRoles();
  $scope.loadUsers();
});
