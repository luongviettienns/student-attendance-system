// Import Service - Handle Excel/CSV imports
app.service('ImportService', ['$q', function($q) {
    
    /**
     * Read Excel/CSV file
     */
    this.readFile = function(file) {
        var deferred = $q.defer();
        
        // Check if XLSX is loaded
        if (typeof XLSX === 'undefined') {
            deferred.reject('Thư viện Excel chưa được tải. Vui lòng refresh trang và thử lại.');
            return deferred.promise;
        }
        
        var reader = new FileReader();
        
        reader.onload = function(e) {
            try {
                var data = e.target.result;
                var workbook = XLSX.read(data, { type: 'binary' });
                var firstSheet = workbook.Sheets[workbook.SheetNames[0]];
                var jsonData = XLSX.utils.sheet_to_json(firstSheet);
                
                deferred.resolve(jsonData);
            } catch (error) {
                deferred.reject('Lỗi đọc file: ' + error.message);
            }
        };
        
        reader.onerror = function() {
            deferred.reject('Lỗi đọc file');
        };
        
        reader.readAsBinaryString(file);
        return deferred.promise;
    };
    
    /**
     * Validate imported data
     */
    this.validate = function(data, schema) {
        var errors = [];
        var validData = [];
        
        data.forEach(function(row, index) {
            var rowErrors = [];
            var isValid = true;
            
            // Check required fields
            schema.forEach(function(field) {
                if (field.required && !row[field.name]) {
                    rowErrors.push(field.label + ' là bắt buộc');
                    isValid = false;
                }
                
                // Validate data type
                if (row[field.name] && field.type) {
                    if (field.type === 'email' && !isValidEmail(row[field.name])) {
                        rowErrors.push(field.label + ' không đúng định dạng email');
                        isValid = false;
                    }
                    
                    if (field.type === 'number' && isNaN(row[field.name])) {
                        rowErrors.push(field.label + ' phải là số');
                        isValid = false;
                    }
                    
                    if (field.type === 'date' && !isValidDate(row[field.name])) {
                        rowErrors.push(field.label + ' không đúng định dạng ngày');
                        isValid = false;
                    }
                }
                
                // Custom validation
                if (row[field.name] && field.validate) {
                    var customError = field.validate(row[field.name], row);
                    if (customError) {
                        rowErrors.push(customError);
                        isValid = false;
                    }
                }
            });
            
            if (rowErrors.length > 0) {
                errors.push({
                    row: index + 2, // +2 because Excel starts at 1 and has header
                    errors: rowErrors,
                    data: row
                });
            }
            
            if (isValid) {
                validData.push(row);
            }
        });
        
        return {
            valid: validData,
            invalid: errors,
            hasErrors: errors.length > 0
        };
    };
    
    /**
     * Download template Excel (Professional with advanced styling & validation)
     */
    this.downloadTemplate = function(filename, columns, referenceData) {
        // Check if XLSX is loaded
        if (typeof XLSX === 'undefined') {
            console.error('SheetJS library not loaded. Please refresh the page.');
            alert('Thư viện Excel chưa được tải. Vui lòng refresh trang và thử lại.');
            return;
        }
        
        var wb = XLSX.utils.book_new();
        wb.Props = {
            Title: "Mẫu Import " + filename,
            Subject: "Template Import Data",
            Author: "Education Management System",
            CreatedDate: new Date()
        };
        
        // ========================================
        // Sheet 1: HƯỚNG DẪN (Enhanced)
        // ========================================
        var instructionData = [
            ['📋 HƯỚNG DẪN SỬ DỤNG MẪU IMPORT SINH VIÊN'],
            [''],
            ['📌 QUY TRÌNH THỰC HIỆN:'],
            ['1️⃣ Điền thông tin vào sheet "Dữ liệu" (không điền vào sheet này)'],
            ['2️⃣ Không thay đổi tên cột ở dòng đầu tiên'],
            ['3️⃣ Mỗi dòng là thông tin của một sinh viên'],
            ['4️⃣ Các cột đánh dấu (*) là bắt buộc phải điền'],
            ['5️⃣ Sau khi điền xong, lưu file và upload vào hệ thống'],
            [''],
            ['📊 THÔNG TIN CÁC CỘT:'],
            [''],
        ];
        
        // Add column descriptions with emojis
        columns.forEach(function(col, index) {
            var required = col.required ? ' ⚠️ BẮT BUỘC' : ' ✅ TÙY CHỌN';
            var emoji = '';
            
            // Add emojis based on field type
            if (col.label.indexOf('Mã SV') !== -1) emoji = '🆔';
            else if (col.label.indexOf('Họ tên') !== -1) emoji = '👤';
            else if (col.label.indexOf('Email') !== -1) emoji = '📧';
            else if (col.label.indexOf('Số điện thoại') !== -1) emoji = '📱';
            else if (col.label.indexOf('Ngày sinh') !== -1) emoji = '🎂';
            else if (col.label.indexOf('Giới tính') !== -1) emoji = '⚧';
            else if (col.label.indexOf('Địa chỉ') !== -1) emoji = '🏠';
            else if (col.label.indexOf('Khoa') !== -1) emoji = '🏛️';
            else if (col.label.indexOf('Ngành') !== -1) emoji = '📚';
            else if (col.label.indexOf('Khóa học') !== -1) emoji = '🎓';
            else emoji = '📝';
            
            var desc = emoji + ' ' + (index + 1) + '. ' + col.label + required;
            if (col.note) {
                desc += '\n   💡 ' + col.note;
            }
            if (col.example) {
                desc += '\n   📋 Ví dụ: ' + col.example;
            }
            instructionData.push([desc]);
        });
        
        instructionData.push(['']);
        instructionData.push(['⚠️ LƯU Ý QUAN TRỌNG:']);
        instructionData.push(['• Mã SV: Định dạng SV + năm + số (VD: SV2024003, SV2024004) - Bắt buộc, không trùng lặp']);
        instructionData.push(['• Họ tên: Họ và tên đầy đủ của sinh viên - Bắt buộc']);
        instructionData.push(['• Email: Đúng định dạng (có @ và domain hợp lệ) - Bắt buộc, không trùng lặp']);
        instructionData.push(['• Số điện thoại: 10-11 chữ số, bắt đầu bằng 0 (VD: 0912345678) - Tùy chọn']);
        instructionData.push(['• Ngày sinh: Định dạng YYYY-MM-DD (VD: 2003-03-15) - Tùy chọn']);
        instructionData.push(['• Giới tính: Chỉ nhập "Nam" hoặc "Nữ" - Tùy chọn']);
        instructionData.push(['• Địa chỉ: Địa chỉ thường trú hoặc tạm trú - Tùy chọn']);
        instructionData.push(['• Mã Ngành: Chỉ dùng MAJ001 hoặc MAJ002 - Bắt buộc, xem sheet "Mã tham khảo"']);
        instructionData.push(['• Niên khóa: Chỉ dùng AY2024 (KHÔNG phải AY2024-2025!) - Tùy chọn, có thể để trống']);
        instructionData.push(['']);
        instructionData.push(['🆘 HỖ TRỢ:']);
        instructionData.push(['Nếu có thắc mắc, vui lòng liên hệ bộ phận hỗ trợ:']);
        instructionData.push(['📞 Hotline: 1900-xxxx']);
        instructionData.push(['📧 Email: support@university.edu.vn']);
        instructionData.push(['']);
        instructionData.push(['📅 Ngày tạo: ' + new Date().toLocaleDateString('vi-VN')]);
        
        var wsInstruction = XLSX.utils.aoa_to_sheet(instructionData);
        
        // Set column width for instruction sheet
        wsInstruction['!cols'] = [{ wch: 100 }];
        
        XLSX.utils.book_append_sheet(wb, wsInstruction, '📋 Hướng dẫn');
        
        // ========================================
        // Sheet 2: DỮ LIỆU (Enhanced)
        // ========================================
        var headers = columns.map(function(col) { 
            return col.label + (col.required ? ' (*)' : ''); 
        });
        
        // ✅ Create 5 sample rows with REAL DATABASE VALUES (can import immediately!)
        var sampleRows = [];
        var sampleData = [
            { 
                code: 'SV2024003', name: 'Nguyễn Văn Cường', email: 'nguyenvancuong@student.edu.vn', 
                phone: '0912345678', dob: '2003-03-15', gender: 'Nam', 
                address: 'Số 10, Đường Lê Lợi, Quận 1, TP.HCM',
                major: 'MAJ001', year: 'AY2024'
            },
            { 
                code: 'SV2024004', name: 'Trần Thị Dung', email: 'tranthidung@student.edu.vn', 
                phone: '0923456789', dob: '2003-07-22', gender: 'Nữ', 
                address: 'Số 25, Đường Nguyễn Huệ, Quận Hai Bà Trưng, Hà Nội',
                major: 'MAJ002', year: 'AY2024'
            },
            { 
                code: 'SV2024005', name: 'Lê Văn Em', email: 'levanem@student.edu.vn', 
                phone: '0934567890', dob: '2003-11-08', gender: 'Nam', 
                address: 'Số 45, Đường Trần Phú, Quận Hải Châu, Đà Nẵng',
                major: 'MAJ001', year: 'AY2024'
            },
            { 
                code: 'SV2024006', name: 'Phạm Thị Hoa', email: 'phamthihoa@student.edu.vn', 
                phone: '0945678901', dob: '2003-05-19', gender: 'Nữ', 
                address: 'Số 78, Đường Cách Mạng Tháng 8, Quận Ninh Kiều, Cần Thơ',
                major: 'MAJ002', year: ''
            },
            { 
                code: 'SV2024007', name: 'Hoàng Văn Khoa', email: 'hoangvankhoa@student.edu.vn', 
                phone: '0956789012', dob: '2003-09-30', gender: 'Nam', 
                address: 'Số 120, Đường Lạch Tray, Quận Ngô Quyền, Hải Phòng',
                major: 'MAJ001', year: 'AY2024'
            }
        ];
        
        for (var i = 0; i < 5; i++) {
            var row = columns.map(function(col) {
                var sample = sampleData[i];
                if (col.label.indexOf('Mã SV') !== -1) {
                    return sample.code;
                } else if (col.label.indexOf('Họ tên') !== -1) {
                    return sample.name;
                } else if (col.label.indexOf('Email') !== -1) {
                    return sample.email;
                } else if (col.label.indexOf('Số điện thoại') !== -1) {
                    return sample.phone;
                } else if (col.label.indexOf('Ngày sinh') !== -1) {
                    return sample.dob;
                } else if (col.label.indexOf('Giới tính') !== -1) {
                    return sample.gender;
                } else if (col.label.indexOf('Địa chỉ') !== -1) {
                    return sample.address;
                } else if (col.label.indexOf('Mã Ngành') !== -1) {
                    return sample.major;
                } else if (col.label.indexOf('Niên khóa') !== -1) {
                    return sample.year;
                }
                return '';
            });
            sampleRows.push(row);
        }
        
        var data = [headers].concat(sampleRows);
        
        var wsData = XLSX.utils.aoa_to_sheet(data);
        
        // Set column widths based on content
        var colWidths = columns.map(function(col) {
            var maxLength = Math.max(col.label.length, (col.example || '').length);
            // Add extra width for emoji and required markers
            return { wch: Math.max(maxLength + 8, 18) };
        });
        wsData['!cols'] = colWidths;
        
        // Add cell styling (basic styling available in free version)
        var range = XLSX.utils.decode_range(wsData['!ref']);
        
        // Style header row
        for (var C = range.s.c; C <= range.e.c; ++C) {
            var cellAddress = XLSX.utils.encode_cell({ r: 0, c: C });
            if (!wsData[cellAddress]) continue;
            
            // Determine if column is required based on header text
            var isRequired = wsData[cellAddress].v && wsData[cellAddress].v.indexOf('(*)') !== -1;
            var headerColor = isRequired ? "DC143C" : "4472C4"; // Red for required, Blue for optional
            
            if (!wsData[cellAddress].s) wsData[cellAddress].s = {};
            wsData[cellAddress].s = {
                font: { bold: true, sz: 12, color: { rgb: "FFFFFF" } },
                fill: { fgColor: { rgb: headerColor } },
                alignment: { horizontal: "center", vertical: "center", wrapText: true },
                border: {
                    top: { style: "medium", color: { rgb: "000000" } },
                    bottom: { style: "medium", color: { rgb: "000000" } },
                    left: { style: "thin", color: { rgb: "000000" } },
                    right: { style: "thin", color: { rgb: "000000" } }
                }
            };
        }
        
        // Style sample data rows (alternating colors)
        for (var R = 1; R <= Math.min(5, range.e.r); ++R) {
            for (var C = range.s.c; C <= range.e.c; ++C) {
                var cellAddress = XLSX.utils.encode_cell({ r: R, c: C });
                if (!wsData[cellAddress]) continue;
                
                if (!wsData[cellAddress].s) wsData[cellAddress].s = {};
                var bgColor = R % 2 === 1 ? "F2F2F2" : "FFFFFF";
                wsData[cellAddress].s = {
                    fill: { fgColor: { rgb: bgColor } },
                    alignment: { horizontal: "left", vertical: "center" },
                    border: {
                        top: { style: "thin", color: { rgb: "CCCCCC" } },
                        bottom: { style: "thin", color: { rgb: "CCCCCC" } },
                        left: { style: "thin", color: { rgb: "CCCCCC" } },
                        right: { style: "thin", color: { rgb: "CCCCCC" } }
                    }
                };
            }
        }
        
        // ========== ADVANCED FEATURES ==========
        
        // Freeze header row (row 1)
        wsData['!freeze'] = { xSplit: 0, ySplit: 1 };
        
        // Auto-filter for header row
        wsData['!autofilter'] = { ref: XLSX.utils.encode_range(range) };
        
        // Add data validations (if supported)
        if (!wsData['!dataValidation']) wsData['!dataValidation'] = [];
        
        // Add dropdown for Gender column if exists
        columns.forEach(function(col, colIndex) {
            if (col.label.indexOf('Giới tính') !== -1) {
                // Create validation for rows 2-1000
                for (var rowNum = 1; rowNum <= 1000; rowNum++) {
                    var cellRef = XLSX.utils.encode_cell({ r: rowNum, c: colIndex });
                    wsData['!dataValidation'].push({
                        type: 'list',
                        allowBlank: true,
                        sqref: cellRef,
                        formulas: ['"Nam,Nữ"']
                    });
                }
            }
        });
        
        // Add cell comments/notes to headers
        columns.forEach(function(col, colIndex) {
            var cellRef = XLSX.utils.encode_cell({ r: 0, c: colIndex });
            if (wsData[cellRef]) {
                var comment = col.required ? 
                    '⚠️ Trường bắt buộc\n' : 
                    '✅ Trường tùy chọn\n';
                
                if (col.note) comment += '\n💡 ' + col.note;
                if (col.example) comment += '\n📋 Ví dụ: ' + col.example;
                
                if (!wsData[cellRef].c) wsData[cellRef].c = [];
                wsData[cellRef].c.push({
                    a: "System",
                    t: comment
                });
            }
        });
        
        XLSX.utils.book_append_sheet(wb, wsData, '📊 Dữ liệu');
        
        // ========================================
        // Sheet 3: DANH SÁCH MÃ (✅ REAL DATABASE VALUES ONLY)
        // ========================================
        var codeData = [
            ['📋 DANH SÁCH MÃ THAM KHẢO (DỮ LIỆU THỰC TẾ TRONG HỆ THỐNG)'],
            [''],
            ['⚠️ CHÚ Ý: Chỉ sử dụng các mã có trong bảng dưới đây. Các mã khác sẽ BỊ LỖI khi import!'],
            [''],
            [''],
            ['📚 DANH SÁCH MÃ NGÀNH (HIỆN CÓ TRONG DATABASE):'],
            ['Mã Ngành', 'Tên Ngành', 'Mã Code', 'Thuộc Khoa'],
            ['MAJ001', 'Công nghệ Phần mềm', 'SE', 'FAC001 - Công nghệ Thông tin'],
            ['MAJ002', 'Khoa học Dữ liệu', 'DS', 'FAC001 - Công nghệ Thông tin'],
            [''],
            ['⚠️ LƯU Ý: Hệ thống hiện chỉ có 2 ngành. Vui lòng liên hệ Admin để thêm ngành mới.'],
            [''],
            [''],
            ['🎓 DANH SÁCH NIÊN KHÓA (HIỆN CÓ TRONG DATABASE):'],
            ['Mã Niên khóa', 'Tên đầy đủ', 'Năm bắt đầu', 'Năm kết thúc', 'Trạng thái'],
            ['AY2024', 'Niên khóa 2024-2025', '2024', '2025', 'Đang hoạt động'],
            [''],
            ['⚠️ LƯU Ý: Hệ thống hiện chỉ có 1 niên khóa. Vui lòng liên hệ Admin để thêm niên khóa mới.'],
            [''],
            [''],
            ['💡 HƯỚNG DẪN SỬ DỤNG:'],
            [''],
            ['✅ MÃ NGÀNH:'],
            ['   • PHẢI sử dụng đúng mã: MAJ001 hoặc MAJ002'],
            ['   • Không được tự tạo mã mới (VD: MAJ003, MAJ004, ...)'],
            ['   • Phân biệt chữ hoa/thường: phải viết MAJ001 (không phải maj001 hay Maj001)'],
            [''],
            ['✅ NIÊN KHÓA:'],
            ['   • Sử dụng mã: AY2024 (KHÔNG PHẢI AY2024-2025)'],
            ['   • Có thể để trống nếu chưa xác định niên khóa'],
            ['   • Phân biệt chữ hoa/thường: phải viết AY2024 (không phải ay2024)'],
            [''],
            [''],
            ['📞 HỖ TRỢ KỸ THUẬT:'],
            ['   • Email: admin@university.edu.vn'],
            ['   • Hotline: 1900-xxxx'],
            ['   • Để thêm Ngành/Niên khóa mới, vui lòng liên hệ Quản trị viên hệ thống']
        ];
        
        var wsCode = XLSX.utils.aoa_to_sheet(codeData);
        wsCode['!cols'] = [
            { wch: 18 },  // Mã Ngành / Mã Niên khóa
            { wch: 30 },  // Tên Ngành / Tên đầy đủ
            { wch: 15 },  // Mã Code / Năm bắt đầu
            { wch: 35 },  // Thuộc Khoa / Năm kết thúc
            { wch: 20 }   // Trạng thái
        ];
        
        XLSX.utils.book_append_sheet(wb, wsCode, '📋 Mã tham khảo');
        
        // ========================================
        // Download file
        // ========================================
        var today = new Date();
        var dateStr = today.getFullYear() + 
                     ('0' + (today.getMonth() + 1)).slice(-2) + 
                     ('0' + today.getDate()).slice(-2);
        
        XLSX.writeFile(wb, filename + '_' + dateStr + '.xlsx');
    };
    
    // Helper functions
    function isValidEmail(email) {
        var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }
    
    function isValidDate(date) {
        return !isNaN(Date.parse(date));
    }
}]);

