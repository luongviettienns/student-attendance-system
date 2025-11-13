# 📋 CÁC CHỨC NĂNG CÒN THIẾU

## ✅ ĐÃ CÓ ĐẦY ĐỦ

1. ✅ **Danh mục môn học, lớp, niên khóa; đăng ký học phần**
2. ✅ **Lịch học/thi; điểm danh theo buổi** (web + API cho mobile)
3. ✅ **Nhập điểm thành phần; công thức tính điểm cuối kỳ** (cấu hình được)
4. ✅ **Cảnh báo vắng > x%; gửi email thông báo** (vừa implement)
5. ✅ **Bảng điểm cá nhân; phúc khảo** (workflow duyệt đầy đủ)
6. ✅ **Báo cáo dữ liệu:** Phân phối điểm, tỷ lệ qua môn, chuyên cần (có data)
7. ✅ **Bảng dữ liệu:** subjects, classes, schedules, enrollments, attendances, grades, appeals, notifications
8. ✅ **NFR:** Kiểm soát quyền sửa điểm (audit logs); Import danh sách SV từ Excel

---

## ❌ CÒN THIẾU

### **1. CẢNH BÁO HỌC LẠI** ✅ **ĐÃ HOÀN THÀNH**

**Trạng thái:** ✅ **HOÀN THÀNH 100%**

**Đã implement:**
- ✅ Bảng `retake_records` với đầy đủ fields
- ✅ Auto-create retake record khi:
  - Vắng > 20% (từ AdvisorService sau khi gửi warning)
  - Điểm < 4.0 (từ GradeService khi update grade)
- ✅ UI cho sinh viên xem môn cần học lại (`/student/retakes`)
- ✅ UI cho advisor quản lý/approve học lại (`/advisor/retakes`)
- ✅ API endpoints đầy đủ (CRUD, filter, pagination)
- ✅ Stored procedures cho business logic

**Ngày hoàn thành:** Vừa xong (Phase 1)

---

### **2. VISUALIZATION CHO BÁO CÁO** ⚠️ **THIẾU MỘT PHẦN**

**Hiện trạng:**
- ✅ Có Chart.js (đã dùng trong student-progress, advisor-progress)
- ✅ Có **line chart** cho GPA và attendance progress
- ✅ Có **statistics** về phân phối điểm (số liệu, chưa có chart)
- ❌ **Thiếu histogram phân phối điểm** (0-2, 2-4, 4-6, 6-8, 8-10)
- ❌ **Thiếu pie chart tỷ lệ qua môn** (Pass vs Fail)
- ❌ **Thiếu bar chart so sánh lớp** (Average GPA/Attendance)
- ❌ **Thiếu dashboard charts** cho báo cáo tổng hợp

**Cần implement:**
- Histogram phân phối điểm trong trang grades
- Pie chart tỷ lệ qua môn trong báo cáo lớp
- Bar chart so sánh các lớp trong dashboard advisor
- Charts cho báo cáo tổng hợp

**Ưu tiên:** ⭐⭐ Trung bình (nice-to-have)  
**Chi phí:** 1-2 ngày  
**Ghi chú:** Có data nhưng chưa có visualization charts đẹp

---

### **3. EXPORT BÁO CÁO** ⚠️ **TÙY CHỌN**

**Hiện trạng:**
- ❌ Không có export Excel/PDF cho báo cáo
- ❌ Không có export bảng điểm
- ❌ Không có export danh sách sinh viên

**Cần implement:**
- Export Excel cho báo cáo
- Export PDF cho bảng điểm
- Export danh sách sinh viên

**Ưu tiên:** ⭐ Thấp (tùy chọn)  
**Chi phí:** 2-3 ngày

---

### **4. NOTIFICATIONS ĐẦY ĐỦ** ⚠️ **TÙY CHỌN**

**Hiện trạng:**
- ✅ Có bảng `notifications`
- ✅ Có notification service
- ⚠️ Chưa có real-time notifications (SignalR)
- ⚠️ Chưa có push notifications cho mobile

**Cần implement:**
- Real-time notifications với SignalR
- Push notifications (nếu có mobile app)

**Ưu tiên:** ⭐ Thấp (tùy chọn)  
**Chi phí:** 2-3 ngày

---

### **5. BACKUP & RESTORE** ⚠️ **TÙY CHỌN**

**Hiện trạng:**
- ❌ Không có chức năng backup database
- ❌ Không có chức năng restore

**Cần implement:**
- Backup database tự động
- Restore database từ backup

**Ưu tiên:** ⭐ Thấp (tùy chọn, chỉ cần cho production)  
**Chi phí:** 1-2 ngày

---

## 📊 TỔNG KẾT

| Chức năng | Trạng thái | Ưu tiên | Chi phí |
|-----------|------------|---------|---------|
| 1. Cảnh báo học lại | ✅ **HOÀN THÀNH** | - | - |
| 2. Visualization báo cáo | ⚠️ Thiếu một phần | ⭐⭐ Trung bình | 1-2 ngày |
| 3. Export báo cáo | ❌ Thiếu | ⭐ Thấp | 2-3 ngày |
| 4. Real-time notifications | ⚠️ Thiếu | ⭐ Thấp | 2-3 ngày |
| 5. Backup & Restore | ❌ Thiếu | ⭐ Thấp | 1-2 ngày |

---

## 🎯 KHUYẾN NGHỊ

### **Cho bài tập lớn:**

**Bắt buộc cần có:**
1. ✅ **Cảnh báo học lại** - ✅ **ĐÃ HOÀN THÀNH**

**Nên có (để điểm cao):**
2. ⚠️ **Visualization báo cáo** (1-2 ngày) - Làm đẹp báo cáo (có line chart, thiếu histogram/pie/bar)

**Tùy chọn:**
3. Export báo cáo
4. Real-time notifications
5. Backup & Restore

---

## 📝 GHI CHÚ

- Hệ thống đã **đầy đủ 95%** các chức năng cốt lõi ✅
- **Cảnh báo học lại** đã **HOÀN THÀNH 100%** ✅
- Các chức năng còn thiếu chủ yếu là **enhancement** và **nice-to-have**:
  - Visualization charts (histogram, pie, bar) - có data nhưng chưa có charts đẹp
  - Export báo cáo - tùy chọn
  - Real-time notifications - tùy chọn
  - Backup & Restore - chỉ cần cho production
- **Đánh giá:** Hệ thống đã **ĐÁP ỨNG ĐẦY ĐỦ** yêu cầu nghiệp vụ cốt lõi

---

**Ngày tạo:** $(date)  
**Phiên bản:** 1.0

