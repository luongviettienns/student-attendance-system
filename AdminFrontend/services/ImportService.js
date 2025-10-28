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
        instructionData.push(['• Email phải đúng định dạng (có @ và domain hợp lệ)']);
        instructionData.push(['• Số điện thoại: 10-11 chữ số, bắt đầu bằng 0']);
        instructionData.push(['• Mã SV: Định dạng SV + số (VD: SV001, SV002)']);
        instructionData.push(['• Mã Khoa, Mã Ngành: Liên hệ quản trị viên để biết mã chính xác']);
        instructionData.push(['• Ngày sinh: Định dạng YYYY-MM-DD (VD: 2000-01-15)']);
        instructionData.push(['• Giới tính: Chỉ nhập "Nam" hoặc "Nữ"']);
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
        
        // Create 5 sample rows with more variety
        var sampleRows = [];
        var sampleData = [
            { name: 'Nguyễn Văn An', email: 'an@example.com', phone: '0912345678', gender: 'Nam', address: 'Hà Nội' },
            { name: 'Trần Thị Bình', email: 'binh@example.com', phone: '0923456789', gender: 'Nữ', address: 'TP.HCM' },
            { name: 'Lê Văn Cường', email: 'cuong@example.com', phone: '0934567890', gender: 'Nam', address: 'Đà Nẵng' },
            { name: 'Phạm Thị Dung', email: 'dung@example.com', phone: '0945678901', gender: 'Nữ', address: 'Cần Thơ' },
            { name: 'Hoàng Văn Em', email: 'em@example.com', phone: '0956789012', gender: 'Nam', address: 'Hải Phòng' }
        ];
        
        for (var i = 0; i < 5; i++) {
            var row = columns.map(function(col) {
                var sample = sampleData[i];
                if (col.label.indexOf('Mã SV') !== -1) {
                    return 'SV' + ('000' + (i + 1)).slice(-3);
                } else if (col.label.indexOf('Họ tên') !== -1) {
                    return sample.name;
                } else if (col.label.indexOf('Email') !== -1) {
                    return sample.email;
                } else if (col.label.indexOf('Số điện thoại') !== -1) {
                    return sample.phone;
                } else if (col.label.indexOf('Ngày sinh') !== -1) {
                    return '200' + (i + 1) + '-0' + (i + 1) + '-1' + (i + 1);
                } else if (col.label.indexOf('Giới tính') !== -1) {
                    return sample.gender;
                } else if (col.label.indexOf('Địa chỉ') !== -1) {
                    return sample.address;
                } else if (col.label.indexOf('Mã Khoa') !== -1) {
                    return (i % 3) + 1; // 1, 2, 3, 1, 2
                } else if (col.label.indexOf('Mã Ngành') !== -1) {
                    return (i % 4) + 1; // 1, 2, 3, 4, 1
                } else if (col.label.indexOf('Khóa học') !== -1) {
                    return 2020 + (i % 4); // 2020, 2021, 2022, 2023, 2020
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
        // Sheet 3: DANH SÁCH MÃ (Enhanced)
        // ========================================
        var codeData = [
            ['📋 DANH SÁCH MÃ THAM KHẢO'],
            [''],
            ['🏛️ DANH SÁCH KHOA:'],
            ['Mã', 'Tên Khoa', 'Ghi chú'],
            ['1', 'Khoa Công nghệ thông tin', 'CNTT'],
            ['2', 'Khoa Kinh tế', 'KT'],
            ['3', 'Khoa Ngoại ngữ', 'NN'],
            ['4', 'Khoa Xây dựng', 'XD'],
            ['5', 'Khoa Điện tử', 'ĐT'],
            [''],
            ['📚 DANH SÁCH NGÀNH:'],
            ['Mã', 'Tên Ngành', 'Thuộc Khoa'],
            ['1', 'Công nghệ thông tin', '1'],
            ['2', 'Khoa học máy tính', '1'],
            ['3', 'An toàn thông tin', '1'],
            ['4', 'Kinh tế học', '2'],
            ['5', 'Quản trị kinh doanh', '2'],
            ['6', 'Kế toán', '2'],
            ['7', 'Tiếng Anh', '3'],
            ['8', 'Tiếng Nhật', '3'],
            [''],
            ['💡 LƯU Ý:'],
            ['• Sử dụng mã số chính xác từ bảng trên'],
            ['• Liên hệ quản trị viên nếu không tìm thấy mã phù hợp'],
            ['• Mã có thể thay đổi theo từng năm học']
        ];
        
        var wsCode = XLSX.utils.aoa_to_sheet(codeData);
        wsCode['!cols'] = [
            { wch: 8 },   // Mã
            { wch: 35 },  // Tên
            { wch: 20 }   // Ghi chú
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

