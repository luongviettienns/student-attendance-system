angular.module("eduApp").controller("AccountController", function ($scope, $http, AuthService) {
  const gatewayBase = "http://localhost:5090";
  const apiAdmin = gatewayBase + "/api-edu/admin";

  /* ============================================================
     🔹 STATE
  ============================================================ */
  $scope.users = [];
  $scope.roles = [];
  $scope.loading = false;

  $scope.showModal = false;   // 👈 thêm dòng này
  $scope.isEdit = false;      // 👈 thêm dòng này
  $scope.formData = {};       // 👈 thêm dòng này

  $scope.pagination = {
    page: 1,
    pageSize: 10,
    totalPages: 1,
    totalCount: 0
  };


  /* ============================================================
     🔹 LOAD DANH SÁCH
  ============================================================ */
  $scope.loadUsers = function () {
    $scope.loading = true;

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
        $scope.users = res.data.data;
        $scope.pagination = res.data.pagination;
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
    $scope.formData = {
      isActive: "true"
    };
    $scope.showModal = true;
  };

  $scope.editUser = function (user) {
    $scope.isEdit = true;
    $scope.formData = angular.copy(user);
    $scope.formData.isActive = String(user.isActive); // chuyển về "true"/"false"
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

    if ($scope.isEdit) {
      // Cập nhật
      $http
        .put(apiAdmin + "/users/" + data.userId, data, {
          headers: AuthService.getAuthHeader()
        })
        .then(res => {
          alert(res.data.message || "Cập nhật thành công");
          $scope.closeModal();
          $scope.loadUsers();
        })
        .catch(err => {
          console.error("❌ Lỗi cập nhật:", err);
          alert(err.data?.message || "Không thể cập nhật người dùng");
        });
    } else {
      // Tạo mới
      $http
        .post(apiAdmin + "/users", data, {
          headers: AuthService.getAuthHeader()
        })
        .then(res => {
          alert(res.data.message || "Thêm người dùng thành công");
          $scope.closeModal();
          $scope.loadUsers();
        })
        .catch(err => {
          console.error("❌ Lỗi thêm mới:", err);
          alert(err.data?.message || "Không thể tạo người dùng");
        });
    }
  };

  /* ============================================================
     🔹 XOÁ MỀM NGƯỜI DÙNG
  ============================================================ */
  $scope.deleteUser = function (user) {
    if (!confirm(`Bạn có chắc muốn xoá người dùng "${user.username}" không?`)) return;

    $http
      .delete(apiAdmin + "/users/" + user.userId, {
        headers: AuthService.getAuthHeader()
      })
      .then(res => {
        alert(res.data.message || "Đã xoá người dùng");
        $scope.loadUsers();
      })
      .catch(err => {
        console.error("❌ Lỗi xoá:", err);
        alert(err.data?.message || "Không thể xoá người dùng");
      });
  };

  /* ============================================================
     🔹 KHỞI TẠO
  ============================================================ */
  $scope.loadRoles();
  $scope.loadUsers();
});
