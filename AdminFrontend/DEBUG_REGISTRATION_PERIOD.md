# Hướng dẫn Debug Trang Quản lý Đợt đăng ký học phần

## 🚀 Cách nhanh nhất: Chạy Script Debug Tự động

1. Mở trang **Quản lý Đợt đăng ký học phần**
2. Nhấn `F12` để mở Developer Tools
3. Chuyển sang tab **Console**
4. Copy và paste toàn bộ nội dung file `js/debug-registration-period.js` vào Console
5. Nhấn Enter
6. Xem kết quả debug chi tiết

Script sẽ tự động:
- ✅ Kiểm tra jQuery, AngularJS, ModalUtils
- ✅ Kiểm tra modal elements trong DOM
- ✅ Kiểm tra controller scope
- ✅ Kiểm tra button và event handlers
- ✅ Kiểm tra CSS
- ✅ Tạo test functions để test modal

## 📋 Các bước debug thủ công

### 1. Mở Developer Tools
- Nhấn `F12` hoặc `Ctrl+Shift+I` (Windows) / `Cmd+Option+I` (Mac)
- Chuyển sang tab **Console**

### 2. Kiểm tra lỗi JavaScript
- Xem có lỗi màu đỏ nào trong Console không
- Ghi lại thông báo lỗi chính xác

### 3. Kiểm tra Modal Elements
Chạy các lệnh sau trong Console:

```javascript
// Kiểm tra modal có tồn tại không
console.log('Modal element:', $('#periodModal').length);
console.log('Overlay element:', $('#modal-overlay').length);

// Kiểm tra class active
console.log('Modal has active:', $('#periodModal').hasClass('active'));
console.log('Overlay has active:', $('#modal-overlay').hasClass('active'));

// Kiểm tra CSS
console.log('Modal display:', $('#periodModal').css('display'));
console.log('Modal visibility:', $('#periodModal').css('visibility'));
console.log('Modal z-index:', $('#periodModal').css('z-index'));
```

### 4. Kiểm tra ModalUtils
```javascript
// Kiểm tra ModalUtils có tồn tại không
console.log('ModalUtils exists:', typeof window.ModalUtils !== 'undefined');
console.log('ModalUtils:', window.ModalUtils);

// Thử mở modal thủ công
if (window.ModalUtils) {
    window.ModalUtils.open('periodModal');
}
```

### 5. Kiểm tra jQuery
```javascript
// Kiểm tra jQuery
console.log('jQuery version:', $.fn.jquery);
console.log('jQuery available:', typeof $ !== 'undefined');
```

### 6. Kiểm tra Controller
```javascript
// Lấy scope của controller
var scope = angular.element(document.querySelector('[ng-controller="RegistrationPeriodController"]')).scope();
console.log('Controller scope:', scope);
console.log('Periods:', scope.periods);
console.log('Current period:', scope.currentPeriod);
```

### 7. Test Modal thủ công
```javascript
// Thử mở modal bằng jQuery
$('#periodModal').addClass('active');
$('#modal-overlay').addClass('active');
$('body').css('overflow', 'hidden');

// Kiểm tra kết quả
console.log('Modal active:', $('#periodModal').hasClass('active'));
console.log('Modal visible:', $('#periodModal').is(':visible'));
```

### 8. Kiểm tra Network Requests
- Chuyển sang tab **Network**
- Refresh trang
- Xem các request API có lỗi không (status 4xx, 5xx)
- Kiểm tra response của các API:
  - `/api-edu/registration-periods`
  - `/api-edu/registration-periods/active`
  - `/api-edu/academic-years`

### 9. Kiểm tra CSS
```javascript
// Kiểm tra CSS của modal
var modal = document.getElementById('periodModal');
var computed = window.getComputedStyle(modal);
console.log('Modal computed styles:', {
    display: computed.display,
    visibility: computed.visibility,
    opacity: computed.opacity,
    zIndex: computed.zIndex,
    position: computed.position
});
```

### 10. Kiểm tra AngularJS
```javascript
// Kiểm tra AngularJS
console.log('AngularJS version:', angular.version.full);
console.log('App module:', angular.module('adminApp'));

// Kiểm tra controller đã load chưa
var controller = angular.element('[ng-controller="RegistrationPeriodController"]');
console.log('Controller element:', controller.length > 0);
```

## Các lỗi thường gặp và cách fix

### Lỗi 1: Modal không hiển thị
**Nguyên nhân có thể:**
- Modal không có class `active`
- CSS bị override
- z-index quá thấp

**Cách fix:**
```javascript
// Thêm class active
$('#periodModal').addClass('active');
$('#modal-overlay').addClass('active');
```

### Lỗi 2: Modal tự động mở khi load trang
**Nguyên nhân có thể:**
- Modal có class `active` mặc định trong HTML
- Code initialization chạy sai

**Cách fix:**
```javascript
// Đóng modal ngay lập tức
$('#periodModal').removeClass('active');
$('#modal-overlay').removeClass('active');
```

### Lỗi 3: Click không mở modal
**Nguyên nhân có thể:**
- Event handler không được gắn
- jQuery chưa load
- Controller chưa khởi tạo

**Cách kiểm tra:**
```javascript
// Kiểm tra event handler
var btn = document.querySelector('[ng-click="showCreateModal()"]');
console.log('Button found:', btn !== null);
console.log('Button onclick:', btn?.onclick);
```

### Lỗi 4: API không trả về dữ liệu
**Cách kiểm tra:**
- Xem tab Network → tìm request `/api-edu/registration-periods`
- Kiểm tra Response tab
- Kiểm tra Status code (200 = OK, 4xx/5xx = lỗi)

## 🔧 Test Functions (sau khi chạy debug script)

Sau khi chạy script debug, bạn có thể dùng các hàm test:

```javascript
// Mở modal thủ công
window.testOpenModal();

// Đóng modal thủ công
window.testCloseModal();

// Force đóng modal (nếu bị stuck)
$('#periodModal').removeClass('active');
$('#modal-overlay').removeClass('active');
$('body').css('overflow', '');
```

## 📸 Thông tin cần cung cấp khi báo lỗi

1. **Lỗi trong Console**: 
   - Copy toàn bộ thông báo lỗi (màu đỏ)
   - Copy tất cả các dòng có `[DEBUG]`

2. **Screenshot**: 
   - Chụp màn hình Console tab
   - Chụp màn hình Network tab (nếu có lỗi API)

3. **Kết quả debug script**: 
   - Copy toàn bộ output của script debug

4. **Browser info**: 
   - Browser: Chrome/Firefox/Edge
   - Version: (xem trong About)
   - OS: Windows/Mac/Linux

5. **Hành động**: 
   - Bạn đang làm gì khi lỗi xảy ra? (click nút, load trang, etc.)
   - Lỗi xảy ra lần đầu hay sau một hành động cụ thể?

6. **Kết quả test functions**:
   - `window.testOpenModal()` có hoạt động không?
   - `window.testCloseModal()` có hoạt động không?

