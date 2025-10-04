app.controller("ProfileController", function($scope, $rootScope, UserService, AuthService, ToastService) {
  $scope.student = {};
  $scope.previewAvatar = null;   
  $scope.selectedFile = null;    
  $scope.isDirty = false;        

  // 🔹 So sánh để bật nút Lưu
  function checkDirty() {
    $scope.isDirty =
      $scope.student.fullName !== ($scope.originalStudent?.fullName) ||
      $scope.student.email !== ($scope.originalStudent?.email) ||
      $scope.student.phone !== ($scope.originalStudent?.phone) ||
      $scope.selectedFile !== null;
  }

  // 🔹 Lấy dữ liệu user hiện tại
  UserService.getProfile()
    .then(function(user) {
      $scope.student = angular.copy(user);
      $scope.originalStudent = angular.copy(user);
    })
    .catch(function(err) {
      if (err.status === 401) {
        ToastService.show("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.", "error");
        AuthService.logout();
        window.location = "#!/login";
      } else if (err.status === 404) {
        ToastService.show("Không tìm thấy thông tin người dùng.", "warning");
      } else if (err.status === 500) {
        ToastService.show("Lỗi máy chủ. Vui lòng thử lại sau.", "error");
      } else {
        ToastService.show("Không tải được thông tin người dùng.", "error");
      }
    });

  // 🔹 Watch field thay đổi
  $scope.$watchGroup(["student.fullName", "student.email", "student.phone"], checkDirty);

  // 🔹 Hàm chọn file avatar
  $scope.chooseFile = function() {
    document.getElementById("avatarInput").click();
  };

  // 🔹 Preview avatar khi chọn ảnh
  $scope.previewImage = function(input) {
    if (input.files && input.files[0]) {
      const reader = new FileReader();
      reader.onload = function(e) {
        $scope.$apply(() => {
          $scope.previewAvatar = e.target.result;
          $scope.selectedFile = input.files[0];
          checkDirty();
        });
      };
      reader.readAsDataURL(input.files[0]);
    }
  };

  // 🔹 Lưu thay đổi
  $scope.updateProfile = function() {
    let formData = new FormData();
    formData.append("FullName", $scope.student.fullName);
    formData.append("Email", $scope.student.email);
    formData.append("Phone", $scope.student.phone);

    if ($scope.selectedFile) {
      formData.append("Avatar", $scope.selectedFile);
    }

    UserService.updateProfile(formData)
      .then(function(result) {
        // cập nhật dữ liệu model
        if (result.avatarUrl) {
          $scope.student.avatarUrl = result.avatarUrl;
        }

        // 🔹 Cập nhật object user hiện tại
        var updatedUser = AuthService.getUser();
        updatedUser.fullName  = $scope.student.fullName;
        updatedUser.email     = $scope.student.email;
        updatedUser.phone     = $scope.student.phone;
        updatedUser.avatarUrl = $scope.student.avatarUrl || "assets/img/default-avatar.png";

        // 🔹 Lưu lại user qua AuthService
        AuthService.setUser(updatedUser);

        // 🔹 Emit event để MainController cập nhật Topbar (dùng ?t để phá cache)
        $rootScope.$emit("profileUpdated", {
          fullName: updatedUser.fullName,
          avatarUrl: updatedUser.avatarUrl + "?t=" + new Date().getTime()
        });

        // Thông báo thành công
        ToastService.show(result.message || "Cập nhật thông tin thành công!", "success");

        // Reset trạng thái form
        $scope.originalStudent = angular.copy($scope.student);
        $scope.previewAvatar = null;
        $scope.selectedFile = null;
        $scope.isDirty = false;
      })
      .catch(function() {
        ToastService.show("Cập nhật thông tin thất bại!", "error");
      });
  };
});
