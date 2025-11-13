# Hướng dẫn Commit với Message Tiếng Việt

## Cấu hình Git (chỉ cần làm 1 lần)

```bash
# Cấu hình encoding cho commit message
git config --global i18n.commitencoding utf-8

# Cấu hình encoding cho log output
git config --global i18n.logoutputencoding utf-8

# Tắt quote path để hiển thị đúng unicode
git config --global core.quotepath false
```

## Cách Commit với Message Tiếng Việt

### Cách 1: Sử dụng file (Khuyến nghị - đảm bảo encoding đúng)

1. Tạo file `commit_msg.txt` với nội dung tiếng Việt đầy đủ dấu:

```bash
# Tạo file commit message
cat > commit_msg.txt << 'EOF'
feat: Thêm tính năng mới

- Mô tả chi tiết thay đổi 1
- Mô tả chi tiết thay đổi 2
- Mô tả chi tiết thay đổi 3
EOF
```

2. Commit với file:

```bash
git add -A
git commit -F commit_msg.txt
```

3. Xóa file tạm:

```bash
rm commit_msg.txt
```

### Cách 2: Sử dụng -m trực tiếp (nếu terminal hỗ trợ UTF-8 tốt)

```bash
git commit -m "feat: Thêm tính năng mới" -m "- Mô tả chi tiết 1" -m "- Mô tả chi tiết 2"
```

## Format Commit Message (Conventional Commits)

### Các loại commit:

- `feat`: Tính năng mới
- `fix`: Sửa lỗi
- `refactor`: Tái cấu trúc code
- `docs`: Thay đổi tài liệu
- `style`: Định dạng code
- `test`: Thêm/sửa test
- `chore`: Công việc bảo trì
- `perf`: Cải thiện hiệu suất
- `ci`: Thay đổi CI/CD

### Cấu trúc:

```
type(scope): Tiêu đề ngắn gọn

- Chi tiết thay đổi 1
- Chi tiết thay đổi 2
- Chi tiết thay đổi 3
```

**Lưu ý:**
- Dòng đầu tiên là tiêu đề ngắn (hiển thị trong danh sách commit)
- Dòng trống để phân cách
- Các dòng tiếp theo là body chi tiết (chỉ hiển thị khi xem chi tiết commit)

## Ví dụ Commit Message

```
feat(lecturer): Thêm tính năng điểm danh

- Thêm form điểm danh cho giảng viên
- Thêm API endpoint lưu điểm danh
- Thêm validation cho ngày và tiết học
```

```
fix(attendance): Sửa lỗi date format

- Sửa lỗi [ngModel:datefmt] trong LecturerAttendanceController
- Thêm ng-model-options để xử lý date format đúng cách
- Thêm watcher để đảm bảo date luôn là string format YYYY-MM-DD
```

## Push lên Remote

```bash
# Push bình thường
git push origin Viettien

# Force push (nếu đã amend commit)
git push --force origin Viettien
```

## Lưu ý

- Luôn kiểm tra `git status` trước khi commit
- Sử dụng file cho commit message phức tạp để đảm bảo encoding đúng
- Commit message tiếng Việt sẽ hiển thị đúng trên GitHub sau khi cấu hình

