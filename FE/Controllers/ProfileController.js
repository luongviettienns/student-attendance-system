app.controller("ProfileController", function ($scope, $rootScope, UserService, AuthService, ToastService) {

  /* ============================================================
     🔹 STATE
  ============================================================ */
  $scope.student = {};
  $scope.previewAvatar = null;
  $scope.selectedFile = null;
  $scope.isDirty = false;

  /* ============================================================
     🔹 HELPER: Kiểm tra form có thay đổi
  ============================================================ */
  function checkDirty() {
    $scope.isDirty =
      $scope.student.fullName !== ($scope.originalStudent?.fullName) ||
      $scope.student.email !== ($scope.originalStudent?.email) ||
      $scope.student.phone !== ($scope.originalStudent?.phone) ||
      $scope.selectedFile !== null;
  }

  /* ============================================================
     🔹 LẤY THÔNG TIN NGƯỜI DÙNG
  ============================================================ */
  UserService.getProfile()
    .then(function (user) {
      $scope.student = angular.copy(user);
      $scope.originalStudent = angular.copy(user);

      // ✅ Nếu thiếu avatar thì fallback
      if (!$scope.student.avatarUrl) {
        $scope.student.avatarUrl = "https://localhost:7033/avatars/default.png";
      }
    })
    .catch(function (err) {
      if (err.status === 401) {
        ToastService.show("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", "error");
        AuthService.logout();
        window.location = "#!/login";
      } else if (err.status === 404) {
        ToastService.show("Không tìm thấy thông tin người dùng.", "warning");
      } else {
        ToastService.show("Không tải được thông tin người dùng.", "error");
      }
    });

  /* ============================================================
     🔹 THEO DÕI THAY ĐỔI INPUT
  ============================================================ */
  $scope.$watchGroup(["student.fullName", "student.email", "student.phone"], checkDirty);

  /* ============================================================
     🔹 CHỌN FILE AVATAR
  ============================================================ */
  $scope.chooseFile = function () {
    document.getElementById("avatarInput").click();
  };

  /* ============================================================
     🔹 PREVIEW ẢNH TRƯỚC KHI LƯU
  ============================================================ */
  $scope.previewImage = function (input) {
    if (input.files && input.files[0]) {
      const reader = new FileReader();
      reader.onload = function (e) {
        $scope.$apply(() => {
          $scope.previewAvatar = e.target.result;
          $scope.selectedFile = input.files[0];
          checkDirty();
        });
      };
      reader.readAsDataURL(input.files[0]);
    }
  };

  /* ============================================================
     🔹 CẬP NHẬT HỒ SƠ
  ============================================================ */
  $scope.updateProfile = function () {
    let formData = new FormData();
    formData.append("FullName", $scope.student.fullName);
    formData.append("Email", $scope.student.email);
    formData.append("Phone", $scope.student.phone);

    if ($scope.selectedFile) {
      formData.append("Avatar", $scope.selectedFile);
    }

    UserService.updateProfile(formData)
      .then(function (result) {
        // ✅ Cập nhật avatar hiển thị ngay lập tức
        if (result.avatarUrl) {
          $scope.student.avatarUrl = result.avatarUrl + "?t=" + new Date().getTime(); // tránh cache
        }

        // ✅ Đồng bộ user trong AuthService
        const updatedUser = AuthService.getUser() || {};
        updatedUser.fullName = $scope.student.fullName;
        updatedUser.email = $scope.student.email;
        updatedUser.phone = $scope.student.phone;
        updatedUser.avatarUrl = $scope.student.avatarUrl || "https://localhost:7033/avatars/default.png";
        AuthService.setUser(updatedUser);

        // ✅ Gửi sự kiện cập nhật avatar cho topbar
        $rootScope.$broadcast("profileUpdated", {
          fullName: updatedUser.fullName,
          avatarUrl: updatedUser.avatarUrl
        });

        // ✅ Thông báo & reset trạng thái form
        ToastService.show(result.message || "Cập nhật thông tin thành công!", "success");
        $scope.originalStudent = angular.copy($scope.student);
        $scope.previewAvatar = null;
        $scope.selectedFile = null;
        $scope.isDirty = false;
      })
      .catch(function (err) {
        console.error("❌ updateProfile error:", err);
        ToastService.show("Cập nhật thông tin thất bại!", "error");
      });
  };

});
