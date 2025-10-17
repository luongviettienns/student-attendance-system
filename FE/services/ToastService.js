angular.module("eduApp")

.factory("ToastService", function ($rootScope, $timeout) {
  // ============================================================
  // ⚙️ STATE CHUNG
  // ============================================================
  $rootScope.toasts = $rootScope.toasts || [];

  const MAX_TOASTS = 3;
  const DEFAULT_DURATION = 4000;

  // ============================================================
  // 🔹 Helper: Xóa toast (với animation)
  // ============================================================
  const removeToast = (toast) => {
    toast.closing = true;
    $timeout(() => {
      const idx = $rootScope.toasts.findIndex(t => t.id === toast.id);
      if (idx >= 0) $rootScope.toasts.splice(idx, 1);
    }, 350); // Thời gian trùng CSS animation
  };

  // ============================================================
  // 🔹 Helper: Tạo toast mới
  // ============================================================
  const createToast = (message, type = "info", duration = DEFAULT_DURATION) => {
    if (!message) return;

    // 🔸 Giới hạn tối đa 3 toast cùng lúc
    if ($rootScope.toasts.length >= MAX_TOASTS) {
      removeToast($rootScope.toasts[0]);
    }

    const toast = {
      id: Date.now(),
      message,
      type,
      closing: false
    };

    $rootScope.toasts.push(toast);

    // 🔸 Tự đóng sau duration
    $timeout(() => removeToast(toast), duration);
  };

  // ============================================================
  // 🚀 Public API
  // ============================================================
  return {
    show: createToast,
    remove: removeToast,
    clearAll: () => ($rootScope.toasts = []),

    // 🔹 Shortcut cho từng loại
    success: (msg, duration) => createToast(msg, "success", duration),
    error:   (msg, duration) => createToast(msg, "error", duration),
    warning: (msg, duration) => createToast(msg, "warning", duration),
    info:    (msg, duration) => createToast(msg, "info", duration)
  };
});
