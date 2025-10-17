angular.module("eduApp").controller("AccountController", function (
  $scope, $http, $timeout, AuthService, ToastService
) {
  const gatewayBase = "https://localhost:7033"; // ✅ Gateway HTTPS
  const apiUsers = `${gatewayBase}/api-edu/account-management`;
  const apiRoles = `${gatewayBase}/api-edu/roles`;

  /* ============================================================
     🔹 STATE
  ============================================================ */
  $scope.users = [];
  $scope.roles = [];
  $scope.loading = false;
  $scope.showModal = false;
  $scope.isEdit = false;
  $scope.formData = {};
  $scope.pagination = { page: 1, pageSize: 10, totalPages: 1, totalCount: 0 };

  $scope.totalUsers = 0;
  $scope.activeUsers = 0;
  $scope.inactiveUsers = 0;

  /* ============================================================
     🔹 LOAD USERS
  ============================================================ */
  $scope.loadUsers = async () => {
    $scope.loading = true;
    $scope.users = [];
    const params = {
      page: $scope.pagination.page,
      pageSize: $scope.pagination.pageSize,
      search: $scope.searchText || null,
      roleId: $scope.filterRoleId || null,
      isActive: $scope.filterStatus !== "" ? $scope.filterStatus : null
    };

    try {
      const res = await $http.get(apiUsers, {
        headers: AuthService.getAuthHeader(),
        params
      });
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

      $scope.totalUsers = $scope.pagination.totalCount || $scope.users.length;
      $scope.activeUsers = $scope.users.filter(u => u.isActive).length;
      $scope.inactiveUsers = $scope.users.filter(u => !u.isActive).length;
    } catch (err) {
      console.error("❌ Lỗi tải danh sách người dùng:", err);
      ToastService.error("Không thể tải danh sách người dùng");
    } finally {
      $scope.loading = false;
    }
  };

  /* ============================================================
     🔹 LOAD ROLES
  ============================================================ */
  $scope.loadRoles = async () => {
    try {
      const res = await $http.get(apiRoles, {
        headers: AuthService.getAuthHeader()
      });
      $scope.roles = res.data.data || [];
    } catch (err) {
      console.error("❌ Lỗi tải vai trò:", err);
      ToastService.warning("Không thể tải danh sách vai trò");
    }
  };

  /* ============================================================
     🔹 TÌM KIẾM & PHÂN TRANG
  ============================================================ */
  $scope.searchUsers = () => {
    $scope.pagination.page = 1;
    $scope.loadUsers();
  };

  $scope.changePage = (page) => {
    if (page < 1 || page > $scope.pagination.totalPages) return;
    $scope.pagination.page = page;
    $scope.loadUsers();
  };

  /* ============================================================
     🔹 MODAL
  ============================================================ */
  $scope.openAddUser = () => {
    $scope.isEdit = false;
    $scope.formData = { username: "", password: "", fullName: "", email: "", phone: "", roleId: "", isActive: "true" };
    $scope.showModal = true;
  };

  $scope.editUser = (user) => {
    $scope.isEdit = true;
    $scope.formData = angular.copy(user);
    $scope.formData.isActive = String(user.isActive);
    delete $scope.formData.password; // tránh gửi password cũ
    $scope.showModal = true;
  };

  $scope.closeModal = () => { $scope.showModal = false; };

  /* ============================================================
     🔹 SAVE (CREATE / UPDATE)
  ============================================================ */
  $scope.saveUser = async () => {
    const data = angular.copy($scope.formData);
    data.isActive = data.isActive === "true";

    // 🔹 Kiểm tra hợp lệ
    if (!data.fullName || !data.roleId) {
      ToastService.warning("Vui lòng nhập đầy đủ họ tên và chọn vai trò!");
      return;
    }
    if (!$scope.isEdit && (!data.username || !data.password)) {
      ToastService.warning("Tài khoản và mật khẩu là bắt buộc khi thêm mới!");
      return;
    }

    try {
      const res = $scope.isEdit
        ? await $http.put(`${apiUsers}/${data.userId}`, data, { headers: AuthService.getAuthHeader() })
        : await $http.post(apiUsers, data, { headers: AuthService.getAuthHeader() });

      ToastService.success(res.data.message || "Lưu thành công");
      $scope.closeModal();
      $scope.loadUsers();
    } catch (err) {
      console.error("❌ Lỗi lưu người dùng:", err);
      ToastService.error(err.data?.message || "Không thể lưu người dùng");
    }
  };

  /* ============================================================
     🔹 DELETE (SOFT DELETE)
  ============================================================ */
  $scope.deleteUser = async (user) => {
    if (!confirm(`Bạn có chắc muốn xoá người dùng "${user.username}" không?`)) return;

    try {
      const res = await $http.delete(`${apiUsers}/${user.userId}`, {
        headers: AuthService.getAuthHeader()
      });
      ToastService.success(res.data.message || "Đã xoá người dùng");
      $scope.loadUsers();
    } catch (err) {
      console.error("❌ Lỗi xoá người dùng:", err);
      ToastService.error(err.data?.message || "Không thể xoá người dùng");
    }
  };

  /* ============================================================
     🔹 KHỞI TẠO
  ============================================================ */
  $scope.loadRoles();
  $scope.loadUsers();
});
