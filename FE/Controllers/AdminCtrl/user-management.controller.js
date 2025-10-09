angular.module("eduApp")
.controller("UserManagementController", function($scope, $http) {

  /* ============================================================
     ⚙️ BIẾN KHỞI TẠO
  ============================================================ */
  $scope.users = [];
  $scope.search = "";
  $scope.filterRole = "";
  $scope.page = 1;
  $scope.pageSize = 5;
  $scope.totalPages = 1;

  /* ============================================================
     📥 TẢI DANH SÁCH NGƯỜI DÙNG (DEMO)
  ============================================================ */
  $scope.loadUsers = function() {
    // 🔹 Dữ liệu mẫu (sau này thay API thật)
    const allUsers = [
      { fullName: "Nguyễn Văn A", username: "a123", email: "a@student.edu.vn", role: "Student", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=1" },
      { fullName: "Trần Thị B", username: "b456", email: "b@student.edu.vn", role: "Student", isActive: false, avatarUrl: "https://i.pravatar.cc/150?img=2" },
      { fullName: "Lê Minh C", username: "c789", email: "c@lecturer.edu.vn", role: "Lecturer", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=3" },
      { fullName: "Phạm Quốc D", username: "d101", email: "d@advisor.edu.vn", role: "Advisor", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=4" },
      { fullName: "Hoàng Văn E", username: "e999", email: "e@admin.edu.vn", role: "Admin", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=5" },
      { fullName: "Đỗ Thị F", username: "f555", email: "f@student.edu.vn", role: "Student", isActive: false, avatarUrl: "https://i.pravatar.cc/150?img=6" },
      { fullName: "Vũ Đức G", username: "g789", email: "g@lecturer.edu.vn", role: "Lecturer", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=7" },
      { fullName: "Ngô Mai H", username: "h222", email: "h@student.edu.vn", role: "Student", isActive: true, avatarUrl: "https://i.pravatar.cc/150?img=8" }
    ];

    // 🔹 Lọc theo vai trò
    let filtered = allUsers;
    if ($scope.filterRole) {
      filtered = filtered.filter(u => u.role === $scope.filterRole);
    }

    // 🔹 Tìm kiếm theo tên hoặc username
    if ($scope.search && $scope.search.trim() !== "") {
      const key = $scope.search.toLowerCase();
      filtered = filtered.filter(u =>
        u.fullName.toLowerCase().includes(key) ||
        u.username.toLowerCase().includes(key)
      );
    }

    // 🔹 Phân trang
    $scope.totalPages = Math.ceil(filtered.length / $scope.pageSize);
    const start = ($scope.page - 1) * $scope.pageSize;
    const end = start + $scope.pageSize;
    $scope.users = filtered.slice(start, end);
  };

  /* ============================================================
     📄 PHÂN TRANG
  ============================================================ */
  $scope.changePage = function(p) {
    if (p >= 1 && p <= $scope.totalPages) {
      $scope.page = p;
      $scope.loadUsers();
    }
  };

  /* ============================================================
     ✏️ CRUD DEMO
  ============================================================ */
  $scope.openAddUser = function() {
    alert("🟢 Thêm người dùng mới (chức năng sẽ dùng modal sau)");
  };

  $scope.importExcel = function() {
    alert("📤 Import danh sách người dùng từ Excel (demo)");
  };

  $scope.exportExcel = function() {
    alert("📥 Xuất danh sách người dùng ra Excel (demo)");
  };

  $scope.editUser = function(u) {
    alert("✏️ Chỉnh sửa người dùng: " + u.fullName);
  };

  $scope.toggleUser = function(u) {
    u.isActive = !u.isActive;
    const state = u.isActive ? "✅ Mở khóa" : "🔒 Khóa";
    alert(state + " tài khoản: " + u.username);
  };

  $scope.deleteUser = function(u) {
    if (confirm("Bạn có chắc muốn xóa " + u.fullName + "?")) {
      $scope.users = $scope.users.filter(x => x !== u);
    }
  };

  /* ============================================================
     🚀 KHỞI CHẠY
  ============================================================ */
  $scope.loadUsers();
});
