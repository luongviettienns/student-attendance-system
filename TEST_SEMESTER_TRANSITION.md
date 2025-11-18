# Hướng dẫn Test: Chuyển học kỳ và kiểm tra điểm số

## Mục đích test

Kiểm tra xem khi chuyển học kỳ:
1. ✅ Điểm HK1 có được **lưu lại** và **hiển thị tốt** không
2. ✅ Điểm HK2 có được **làm mới** (không có điểm từ HK1) không
3. ✅ Hệ thống có **phân biệt** điểm theo học kỳ đúng không

---

## Cách 1: Test bằng SQL Script

### Bước 1: Chạy script test

```sql
-- Chạy file SQL/Test_Semester_Transition_Grades.sql
-- Script sẽ tự động:
-- 1. Tạo dữ liệu test (nếu chưa có)
-- 2. Kiểm tra điểm HK1 trước khi chuyển
-- 3. Chuyển học kỳ
-- 4. Kiểm tra điểm sau khi chuyển
-- 5. Test query điểm theo học kỳ
-- 6. Khôi phục học kỳ về trạng thái ban đầu
```

### Bước 2: Xem kết quả

Script sẽ hiển thị:
- ✅ Điểm HK1 vẫn còn nguyên (ĐÚNG)
- ✅ Query điểm HK1: X điểm
- ✅ Query điểm HK2: Y điểm
- ✅ Học kỳ hiện tại đã được cập nhật: HK2

---

## Cách 2: Test bằng UI (Khuyến nghị)

### Chuẩn bị dữ liệu

1. **Đảm bảo có năm học đang active**
   - Vào: **Quản lý Năm học** (`/school-years`)
   - Kiểm tra có năm học với `current_semester = 1`

2. **Tạo lớp học HK1 và HK2**
   - Vào: **Quản lý Lớp học** (`/classes`)
   - Tạo lớp HK1: `semester = 1`, `school_year_id = [năm học hiện tại]`
   - Tạo lớp HK2: `semester = 2`, `school_year_id = [năm học hiện tại]`

3. **Đăng ký sinh viên vào lớp HK1**
   - Vào: **Quản lý Đăng ký** (`/enrollments`)
   - Đăng ký sinh viên vào lớp HK1
   - Status: `APPROVED`

4. **Nhập điểm cho lớp HK1**
   - Vào: **Quản lý Điểm** (`/lecturer/grades`)
   - Chọn lớp HK1
   - Nhập điểm giữa kỳ và cuối kỳ cho sinh viên
   - Lưu điểm

### Test Case 1: Kiểm tra điểm HK1 trước khi chuyển

1. **Xem điểm sinh viên**
   - Vào: **Xem điểm** (`/student/grades`)
   - Chọn năm học hiện tại
   - Chọn "Học kỳ 1"
   - **Kỳ vọng**: Hiển thị điểm của lớp HK1

2. **Xem điểm từ phía Advisor**
   - Vào: **Quản lý Sinh viên** → Chọn sinh viên → Tab "Điểm số"
   - Filter: Năm học hiện tại, Học kỳ 1
   - **Kỳ vọng**: Hiển thị điểm của lớp HK1

### Test Case 2: Chuyển học kỳ

1. **Chuyển học kỳ**
   - Vào: **Quản lý Năm học** (`/school-years`)
   - Click nút **"Chuyển học kỳ tự động"**
   - Xác nhận chuyển
   - **Kỳ vọng**: 
     - Thông báo thành công
     - Học kỳ hiện tại chuyển từ 1 → 2
     - GPA HK1 được tính tự động

2. **Kiểm tra học kỳ hiện tại**
   - Vào: **Quản lý Năm học** (`/school-years`)
   - Xem phần "Năm học hiện tại"
   - **Kỳ vọng**: Hiển thị "Học kỳ 2"

### Test Case 3: Kiểm tra điểm HK1 sau khi chuyển

1. **Xem điểm HK1 (vẫn phải còn)**
   - Vào: **Xem điểm** (`/student/grades`)
   - Chọn năm học hiện tại
   - Chọn "Học kỳ 1"
   - **Kỳ vọng**: 
     - ✅ Vẫn hiển thị điểm của lớp HK1
     - ✅ Điểm không bị thay đổi
     - ✅ Điểm không bị mất

2. **Xem điểm từ phía Advisor**
   - Vào: **Quản lý Sinh viên** → Chọn sinh viên → Tab "Điểm số"
   - Filter: Năm học hiện tại, Học kỳ 1
   - **Kỳ vọng**: 
     - ✅ Vẫn hiển thị điểm của lớp HK1
     - ✅ Điểm giữa kỳ và cuối kỳ không đổi

### Test Case 4: Kiểm tra điểm HK2 (làm mới)

1. **Xem điểm HK2**
   - Vào: **Xem điểm** (`/student/grades`)
   - Chọn năm học hiện tại
   - Chọn "Học kỳ 2"
   - **Kỳ vọng**: 
     - ✅ Không có điểm (nếu chưa nhập)
     - ✅ Hoặc chỉ hiển thị điểm của lớp HK2 (nếu đã nhập)

2. **Đăng ký lớp HK2 và nhập điểm**
   - Đăng ký sinh viên vào lớp HK2
   - Nhập điểm cho lớp HK2
   - **Kỳ vọng**: 
     - ✅ Điểm HK2 hiển thị riêng biệt
     - ✅ Không bị trộn lẫn với điểm HK1

### Test Case 5: Kiểm tra GPA

1. **Xem GPA HK1**
   - Vào: **Xem điểm** (`/student/grades`)
   - Chọn năm học hiện tại
   - Chọn "Học kỳ 1"
   - Xem phần "Tóm tắt"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA HK1
     - ✅ Hiển thị số tín chỉ HK1
     - ✅ Hiển thị xếp loại HK1

2. **Xem GPA HK2**
   - Chọn "Học kỳ 2"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA HK2 (nếu đã có điểm)
     - ✅ Hoặc GPA = 0 nếu chưa có điểm

3. **Xem GPA cả năm**
   - Chọn "Tất cả"
   - **Kỳ vọng**: 
     - ✅ Hiển thị GPA tích lũy
     - ✅ Bao gồm cả HK1 và HK2

---

## Checklist Test

### ✅ Test Pass nếu:

- [ ] Điểm HK1 vẫn còn nguyên sau khi chuyển học kỳ
- [ ] Điểm HK1 hiển thị đúng khi filter "Học kỳ 1"
- [ ] Điểm HK2 không có điểm từ HK1 (làm mới)
- [ ] Điểm HK2 hiển thị riêng biệt khi filter "Học kỳ 2"
- [ ] GPA HK1 được tính và lưu lại
- [ ] GPA HK2 được tính riêng (không trộn với HK1)
- [ ] Học kỳ hiện tại được cập nhật đúng (1 → 2)
- [ ] Query điểm theo học kỳ hoạt động đúng

### ❌ Test Fail nếu:

- [ ] Điểm HK1 bị mất sau khi chuyển học kỳ
- [ ] Điểm HK1 bị thay đổi sau khi chuyển học kỳ
- [ ] Điểm HK2 hiển thị điểm từ HK1
- [ ] Không thể filter điểm theo học kỳ
- [ ] GPA bị tính sai hoặc trộn lẫn giữa các học kỳ

---

## Lưu ý

1. **Điểm số không tự động làm mới**: 
   - Điểm số được lưu trong bảng `grades`, liên kết với `enrollments` → `classes`
   - Mỗi lớp có `semester` riêng, không tự động cập nhật
   - Khi chuyển học kỳ, điểm HK1 vẫn thuộc về lớp HK1

2. **Điểm HK2 sẽ "làm mới" tự nhiên**:
   - Khi tạo lớp HK2 mới, lớp đó chưa có điểm
   - Sinh viên đăng ký lớp HK2 mới, điểm sẽ được nhập riêng
   - Điểm HK2 không bị trộn với điểm HK1 vì filter theo `classes.semester`

3. **GPA được tính riêng theo học kỳ**:
   - GPA HK1 được tính khi chuyển học kỳ
   - GPA HK2 sẽ được tính khi có điểm HK2
   - Mỗi GPA được lưu riêng trong bảng `gpas` với `semester` tương ứng

---

## Troubleshooting

### Vấn đề: Điểm HK1 không hiển thị sau khi chuyển học kỳ

**Nguyên nhân có thể**:
- Filter không đúng (đang filter theo `current_semester` thay vì `classes.semester`)
- Query không join đúng bảng `classes`

**Giải pháp**:
- Kiểm tra stored procedure `sp_GetGradesByStudentSchoolYear`
- Đảm bảo filter theo `c.semester` chứ không phải `sy.current_semester`

### Vấn đề: Điểm HK2 hiển thị điểm từ HK1

**Nguyên nhân có thể**:
- Lớp HK2 có `semester` sai (đang là 1 thay vì 2)
- Query không filter đúng theo `semester`

**Giải pháp**:
- Kiểm tra `classes.semester` của lớp HK2
- Đảm bảo query filter đúng: `WHERE c.semester = @SemesterInt`

---

## Kết luận

Sau khi test, bạn sẽ biết được:
1. ✅ Điểm HK1 có được lưu lại và hiển thị tốt không
2. ✅ Điểm HK2 có được làm mới (không có điểm từ HK1) không
3. ✅ Hệ thống có phân biệt điểm theo học kỳ đúng không

Nếu tất cả test case đều pass → Hệ thống hoạt động đúng! ✅

