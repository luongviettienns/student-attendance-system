using EducationManagement.Common.DTOs.Student;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    /// <summary>
    /// Service để xử lý import/export Excel cho sinh viên
    /// </summary>
    public class StudentExcelService
    {
        private readonly StudentService _studentService;

        public StudentExcelService(StudentService studentService)
        {
            _studentService = studentService;
        }

        /// <summary>
        /// Tạo file Excel mẫu để import sinh viên
        /// </summary>
        public async Task<byte[]> GenerateImportTemplateAsync()
        {
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            
            using var package = new ExcelPackage();
            var worksheet = package.Workbook.Worksheets.Add("Mẫu Import Sinh Viên");

            // Tiêu đề
            worksheet.Cells[1, 1].Value = "MẪU IMPORT SINH VIÊN";
            worksheet.Cells[1, 1, 1, 8].Merge = true;
            worksheet.Cells[1, 1].Style.Font.Size = 16;
            worksheet.Cells[1, 1].Style.Font.Bold = true;
            worksheet.Cells[1, 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
            worksheet.Cells[1, 1].Style.Fill.PatternType = ExcelFillStyle.Solid;
            worksheet.Cells[1, 1].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(68, 114, 196));
            worksheet.Cells[1, 1].Style.Font.Color.SetColor(System.Drawing.Color.White);

            // Ghi chú quan trọng
            worksheet.Cells[2, 1].Value = "LƯU Ý KHI IMPORT:";
            worksheet.Cells[2, 1, 2, 8].Merge = true;
            worksheet.Cells[2, 1].Style.Font.Bold = true;
            worksheet.Cells[2, 1].Style.Font.Color.SetColor(System.Drawing.Color.Red);
            worksheet.Cells[2, 1].Style.Fill.PatternType = ExcelFillStyle.Solid;
            worksheet.Cells[2, 1].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(255, 242, 204));

            worksheet.Cells[3, 1].Value = "1. Mã sinh viên (StudentCode): Bắt buộc, không được trùng, tối đa 20 ký tự";
            worksheet.Cells[3, 1, 3, 8].Merge = true;
            worksheet.Cells[4, 1].Value = "2. Họ và tên (FullName): Bắt buộc, tối đa 150 ký tự";
            worksheet.Cells[4, 1, 4, 8].Merge = true;
            worksheet.Cells[5, 1].Value = "3. Email: Định dạng email hợp lệ, tối đa 150 ký tự";
            worksheet.Cells[5, 1, 5, 8].Merge = true;
            worksheet.Cells[6, 1].Value = "4. Số điện thoại (Phone): Tối đa 20 ký tự, chỉ chứa số";
            worksheet.Cells[6, 1, 6, 8].Merge = true;
            worksheet.Cells[7, 1].Value = "5. Ngày sinh (DateOfBirth): Định dạng dd/MM/yyyy hoặc yyyy-MM-dd";
            worksheet.Cells[7, 1, 7, 8].Merge = true;
            worksheet.Cells[8, 1].Value = "6. Giới tính (Gender): Nam, Nữ hoặc để trống";
            worksheet.Cells[8, 1, 8, 8].Merge = true;
            worksheet.Cells[9, 1].Value = "7. Địa chỉ (Address): Tùy chọn";
            worksheet.Cells[9, 1, 9, 8].Merge = true;
            worksheet.Cells[10, 1].Value = "8. Mã ngành (MajorId): Bắt buộc, phải tồn tại trong hệ thống";
            worksheet.Cells[10, 1, 10, 8].Merge = true;
            worksheet.Cells[11, 1].Value = "9. Mã năm học (AcademicYearId): Tùy chọn, phải tồn tại trong hệ thống nếu có";
            worksheet.Cells[11, 1, 11, 8].Merge = true;

            // Header row
            int headerRow = 13;
            var headers = new[]
            {
                "Mã sinh viên*",
                "Họ và tên*",
                "Email*",
                "Số điện thoại",
                "Ngày sinh",
                "Giới tính",
                "Địa chỉ",
                "Mã ngành*",
                "Mã năm học"
            };

            for (int i = 0; i < headers.Length; i++)
            {
                worksheet.Cells[headerRow, i + 1].Value = headers[i];
                worksheet.Cells[headerRow, i + 1].Style.Font.Bold = true;
                worksheet.Cells[headerRow, i + 1].Style.Fill.PatternType = ExcelFillStyle.Solid;
                worksheet.Cells[headerRow, i + 1].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(217, 225, 242));
                worksheet.Cells[headerRow, i + 1].Style.Border.BorderAround(ExcelBorderStyle.Thin);
                worksheet.Cells[headerRow, i + 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
            }

            // Ví dụ dữ liệu
            int exampleRow = headerRow + 1;
            worksheet.Cells[exampleRow, 1].Value = "SV001";
            worksheet.Cells[exampleRow, 2].Value = "Nguyễn Văn A";
            worksheet.Cells[exampleRow, 3].Value = "sv001@example.com";
            worksheet.Cells[exampleRow, 4].Value = "0123456789";
            worksheet.Cells[exampleRow, 5].Value = "01/01/2000";
            worksheet.Cells[exampleRow, 6].Value = "Nam";
            worksheet.Cells[exampleRow, 7].Value = "123 Đường ABC, Quận XYZ";
            worksheet.Cells[exampleRow, 8].Value = "CNTT";
            worksheet.Cells[exampleRow, 9].Value = "2024-2025";

            // Format example row
            for (int i = 1; i <= headers.Length; i++)
            {
                worksheet.Cells[exampleRow, i].Style.Border.BorderAround(ExcelBorderStyle.Thin);
                worksheet.Cells[exampleRow, i].Style.Fill.PatternType = ExcelFillStyle.Solid;
                worksheet.Cells[exampleRow, i].Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(242, 242, 242));
            }

            // Auto-fit columns
            for (int i = 1; i <= headers.Length; i++)
            {
                worksheet.Column(i).AutoFit();
                if (worksheet.Column(i).Width > 30)
                    worksheet.Column(i).Width = 30;
            }

            // Set row heights
            worksheet.Row(1).Height = 25;
            worksheet.Row(headerRow).Height = 20;

            return package.GetAsByteArray();
        }

        /// <summary>
        /// Import sinh viên từ file Excel
        /// </summary>
        public async Task<ImportExcelResultDto> ImportFromExcelAsync(Stream fileStream, string createdBy)
        {
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
            
            var result = new ImportExcelResultDto
            {
                Errors = new List<ImportErrorDto>(),
                SuccessCount = 0,
                ErrorCount = 0
            };

            try
            {
                // Đảm bảo stream ở vị trí đầu
                if (fileStream.CanSeek)
                    fileStream.Position = 0;

                using var package = new ExcelPackage(fileStream);
                
                if (package.Workbook.Worksheets.Count == 0)
                {
                    result.Errors.Add(new ImportErrorDto
                    {
                        RowNumber = 0,
                        StudentCode = "",
                        ErrorMessage = "File Excel không có worksheet nào"
                    });
                    result.ErrorCount++;
                    return result;
                }

                var worksheet = package.Workbook.Worksheets.FirstOrDefault();

                if (worksheet == null)
                {
                    result.Errors.Add(new ImportErrorDto
                    {
                        RowNumber = 0,
                        StudentCode = "",
                        ErrorMessage = "File Excel không có worksheet nào"
                    });
                    result.ErrorCount++;
                    return result;
                }

                // Kiểm tra worksheet có dữ liệu không
                if (worksheet.Dimension == null)
                {
                    result.Errors.Add(new ImportErrorDto
                    {
                        RowNumber = 0,
                        StudentCode = "",
                        ErrorMessage = "File Excel không có dữ liệu"
                    });
                    result.ErrorCount++;
                    return result;
                }

                // Tìm dòng header (có thể ở dòng 13 hoặc dòng đầu tiên có "Mã sinh viên")
                int headerRow = 1;
                int maxSearchRow = Math.Min(20, worksheet.Dimension.End.Row);
                for (int row = 1; row <= maxSearchRow; row++)
                {
                    var cellValue = worksheet.Cells[row, 1].Text?.Trim() ?? "";
                    if (cellValue.Contains("Mã sinh viên") || cellValue.Contains("StudentCode") || 
                        cellValue.Contains("Mã sinh viên*"))
                    {
                        headerRow = row;
                        break;
                    }
                }

                // Đọc header để xác định cột
                var columnMap = new Dictionary<string, int>();
                int maxColumn = worksheet.Dimension?.End.Column ?? 9;
                for (int col = 1; col <= maxColumn; col++)
                {
                    var headerValue = worksheet.Cells[headerRow, col].Text?.Trim() ?? "";
                    if (headerValue.Contains("Mã sinh viên") || headerValue.Contains("StudentCode"))
                        columnMap["StudentCode"] = col;
                    else if (headerValue.Contains("Họ và tên") || headerValue.Contains("FullName"))
                        columnMap["FullName"] = col;
                    else if (headerValue.Contains("Email"))
                        columnMap["Email"] = col;
                    else if (headerValue.Contains("Số điện thoại") || headerValue.Contains("Phone"))
                        columnMap["Phone"] = col;
                    else if (headerValue.Contains("Ngày sinh") || headerValue.Contains("DateOfBirth"))
                        columnMap["DateOfBirth"] = col;
                    else if (headerValue.Contains("Giới tính") || headerValue.Contains("Gender"))
                        columnMap["Gender"] = col;
                    else if (headerValue.Contains("Địa chỉ") || headerValue.Contains("Address"))
                        columnMap["Address"] = col;
                    else if (headerValue.Contains("Mã ngành") || headerValue.Contains("MajorId"))
                        columnMap["MajorId"] = col;
                    else if (headerValue.Contains("Mã năm học") || headerValue.Contains("AcademicYearId"))
                        columnMap["AcademicYearId"] = col;
                }

                // Kiểm tra các cột bắt buộc
                if (!columnMap.ContainsKey("StudentCode") || !columnMap.ContainsKey("FullName") || 
                    !columnMap.ContainsKey("Email") || !columnMap.ContainsKey("MajorId"))
                {
                    result.Errors.Add(new ImportErrorDto
                    {
                        RowNumber = 0,
                        StudentCode = "",
                        ErrorMessage = "File Excel thiếu các cột bắt buộc: Mã sinh viên, Họ và tên, Email, Mã ngành"
                    });
                    result.ErrorCount++;
                    return result;
                }

                // Đọc dữ liệu từ dòng sau header
                var students = new List<StudentImportDto>();
                int dataStartRow = headerRow + 1;
                int endRow = worksheet.Dimension.End.Row;

                for (int row = dataStartRow; row <= endRow; row++)
                {
                    // Kiểm tra xem dòng có dữ liệu không
                    var studentCodeCell = worksheet.Cells[row, columnMap["StudentCode"]];
                    var studentCode = studentCodeCell?.Text?.Trim() ?? "";
                    
                    // Bỏ qua dòng trống hoặc dòng chỉ có khoảng trắng
                    if (string.IsNullOrWhiteSpace(studentCode))
                        continue;

                    var student = new StudentImportDto
                    {
                        StudentCode = studentCode,
                        FullName = worksheet.Cells[row, columnMap["FullName"]].Text?.Trim() ?? "",
                        Email = worksheet.Cells[row, columnMap["Email"]].Text?.Trim() ?? "",
                        Phone = columnMap.ContainsKey("Phone") ? worksheet.Cells[row, columnMap["Phone"]].Text?.Trim() : null,
                        Gender = columnMap.ContainsKey("Gender") ? worksheet.Cells[row, columnMap["Gender"]].Text?.Trim() : null,
                        Address = columnMap.ContainsKey("Address") ? worksheet.Cells[row, columnMap["Address"]].Text?.Trim() : null,
                        MajorId = worksheet.Cells[row, columnMap["MajorId"]].Text?.Trim() ?? "",
                        AcademicYearId = columnMap.ContainsKey("AcademicYearId") ? worksheet.Cells[row, columnMap["AcademicYearId"]].Text?.Trim() : null
                    };

                    // Parse ngày sinh
                    if (columnMap.ContainsKey("DateOfBirth"))
                    {
                        var dobText = worksheet.Cells[row, columnMap["DateOfBirth"]].Text?.Trim() ?? "";
                        if (!string.IsNullOrWhiteSpace(dobText))
                        {
                            if (DateTime.TryParse(dobText, out var dob))
                            {
                                student.DateOfBirth = dob;
                            }
                            else
                            {
                                result.Errors.Add(new ImportErrorDto
                                {
                                    RowNumber = row,
                                    StudentCode = student.StudentCode,
                                    ErrorMessage = $"Ngày sinh không hợp lệ: {dobText}. Vui lòng sử dụng định dạng dd/MM/yyyy"
                                });
                                result.ErrorCount++;
                                continue;
                            }
                        }
                    }

                    // Validate dữ liệu
                    var validationErrors = ValidateStudentImport(student, row);
                    if (validationErrors.Any())
                    {
                        result.Errors.AddRange(validationErrors);
                        result.ErrorCount += validationErrors.Count;
                        continue;
                    }

                    students.Add(student);
                }

                if (students.Count == 0)
                {
                    result.Errors.Add(new ImportErrorDto
                    {
                        RowNumber = 0,
                        StudentCode = "",
                        ErrorMessage = "Không có dữ liệu hợp lệ để import"
                    });
                    result.ErrorCount++;
                    return result;
                }

                // Import vào database
                var importResult = await _studentService.ImportStudentsBatchAsync(students, createdBy);
                
                result.SuccessCount = importResult.SuccessCount;
                result.ErrorCount += importResult.ErrorCount;
                result.Errors.AddRange(importResult.Errors);

                return result;
            }
            catch (Exception ex)
            {
                result.Errors.Add(new ImportErrorDto
                {
                    RowNumber = 0,
                    StudentCode = "",
                    ErrorMessage = $"Lỗi khi đọc file Excel: {ex.Message}"
                });
                result.ErrorCount++;
                return result;
            }
        }

        /// <summary>
        /// Validate dữ liệu sinh viên trước khi import
        /// </summary>
        private List<ImportErrorDto> ValidateStudentImport(StudentImportDto student, int rowNumber)
        {
            var errors = new List<ImportErrorDto>();

            // Validate StudentCode
            if (string.IsNullOrWhiteSpace(student.StudentCode))
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = "",
                    ErrorMessage = "Mã sinh viên không được để trống"
                });
            }
            else if (student.StudentCode.Length > 20)
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Mã sinh viên không được vượt quá 20 ký tự"
                });
            }

            // Validate FullName
            if (string.IsNullOrWhiteSpace(student.FullName))
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Họ và tên không được để trống"
                });
            }
            else if (student.FullName.Length > 150)
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Họ và tên không được vượt quá 150 ký tự"
                });
            }

            // Validate Email
            if (string.IsNullOrWhiteSpace(student.Email))
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Email không được để trống"
                });
            }
            else if (student.Email.Length > 150)
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Email không được vượt quá 150 ký tự"
                });
            }
            else if (!IsValidEmail(student.Email))
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Email không đúng định dạng"
                });
            }

            // Validate Phone
            if (!string.IsNullOrWhiteSpace(student.Phone))
            {
                if (student.Phone.Length > 20)
                {
                    errors.Add(new ImportErrorDto
                    {
                        RowNumber = rowNumber,
                        StudentCode = student.StudentCode,
                        ErrorMessage = "Số điện thoại không được vượt quá 20 ký tự"
                    });
                }
                else if (!Regex.IsMatch(student.Phone, @"^[0-9\s\-\+\(\)]+$"))
                {
                    errors.Add(new ImportErrorDto
                    {
                        RowNumber = rowNumber,
                        StudentCode = student.StudentCode,
                        ErrorMessage = "Số điện thoại chỉ được chứa số và các ký tự: +, -, (, ), khoảng trắng"
                    });
                }
            }

            // Validate Gender
            if (!string.IsNullOrWhiteSpace(student.Gender))
            {
                var gender = student.Gender.Trim().ToLower();
                if (gender != "nam" && gender != "nữ" && gender != "nu" && gender != "male" && gender != "female")
                {
                    errors.Add(new ImportErrorDto
                    {
                        RowNumber = rowNumber,
                        StudentCode = student.StudentCode,
                        ErrorMessage = "Giới tính phải là: Nam, Nữ, Male, Female hoặc để trống"
                    });
                }
            }

            // Validate MajorId
            if (string.IsNullOrWhiteSpace(student.MajorId))
            {
                errors.Add(new ImportErrorDto
                {
                    RowNumber = rowNumber,
                    StudentCode = student.StudentCode,
                    ErrorMessage = "Mã ngành không được để trống"
                });
            }

            return errors;
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var regex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.IgnoreCase);
                return regex.IsMatch(email);
            }
            catch
            {
                return false;
            }
        }
    }

    /// <summary>
    /// DTO cho kết quả import Excel
    /// </summary>
    public class ImportExcelResultDto
    {
        public int SuccessCount { get; set; }
        public int ErrorCount { get; set; }
        public List<ImportErrorDto> Errors { get; set; } = new();
    }
}

