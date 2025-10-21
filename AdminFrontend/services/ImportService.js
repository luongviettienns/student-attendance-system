// Import Service - Handle Excel/CSV imports
app.service('ImportService', ['$q', function($q) {
    
    /**
     * Read Excel/CSV file
     */
    this.readFile = function(file) {
        var deferred = $q.defer();
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
     * Download template Excel
     */
    this.downloadTemplate = function(filename, columns) {
        // Create header row
        var headers = columns.map(function(col) { return col.label; });
        
        // Create sample data row (optional)
        var sampleRow = columns.map(function(col) { return col.example || ''; });
        
        var data = [headers, sampleRow];
        
        // Create workbook
        var ws = XLSX.utils.aoa_to_sheet(data);
        var wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'Template');
        
        // Download
        XLSX.writeFile(wb, filename + '_template.xlsx');
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

