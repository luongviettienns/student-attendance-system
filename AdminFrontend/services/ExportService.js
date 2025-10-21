// Export Service - Handle Excel/CSV/PDF exports
app.service('ExportService', ['$window', function($window) {
    
    /**
     * Export to CSV
     */
    this.exportToCSV = function(data, filename, columns) {
        if (!data || data.length === 0) {
            alert('Không có dữ liệu để xuất');
            return;
        }
        
        // Build CSV header
        var headers = columns.map(function(col) { return col.label; });
        var csvContent = headers.join(',') + '\n';
        
        // Build CSV rows
        data.forEach(function(item) {
            var row = columns.map(function(col) {
                var value = col.field.split('.').reduce(function(obj, key) {
                    return obj ? obj[key] : '';
                }, item);
                
                // Escape commas and quotes
                if (value === null || value === undefined) value = '';
                value = String(value).replace(/"/g, '""');
                if (value.includes(',') || value.includes('"') || value.includes('\n')) {
                    value = '"' + value + '"';
                }
                return value;
            });
            csvContent += row.join(',') + '\n';
        });
        
        // Download file
        this.downloadFile(csvContent, filename + '.csv', 'text/csv;charset=utf-8;');
    };
    
    /**
     * Export to Excel (using HTML table trick)
     */
    this.exportToExcel = function(data, filename, columns) {
        if (!data || data.length === 0) {
            alert('Không có dữ liệu để xuất');
            return;
        }
        
        // Build HTML table
        var html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">';
        html += '<head><meta charset="UTF-8"><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>';
        html += '<x:Name>Sheet1</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet>';
        html += '</x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body>';
        html += '<table border="1">';
        
        // Header row
        html += '<thead><tr>';
        columns.forEach(function(col) {
            html += '<th>' + col.label + '</th>';
        });
        html += '</tr></thead>';
        
        // Data rows
        html += '<tbody>';
        data.forEach(function(item) {
            html += '<tr>';
            columns.forEach(function(col) {
                var value = col.field.split('.').reduce(function(obj, key) {
                    return obj ? obj[key] : '';
                }, item);
                html += '<td>' + (value || '') + '</td>';
            });
            html += '</tr>';
        });
        html += '</tbody></table></body></html>';
        
        // Download file
        this.downloadFile(html, filename + '.xls', 'application/vnd.ms-excel');
    };
    
    /**
     * Download file helper
     */
    this.downloadFile = function(content, filename, mimeType) {
        var blob = new Blob(['\ufeff' + content], { type: mimeType });
        var link = document.createElement('a');
        
        if (navigator.msSaveBlob) { // IE 10+
            navigator.msSaveBlob(blob, filename);
        } else {
            link.href = URL.createObjectURL(blob);
            link.download = filename;
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    };
    
    /**
     * Print table as PDF (using browser print)
     */
    this.printToPDF = function(title, data, columns) {
        var printWindow = $window.open('', '_blank');
        var html = this.buildPrintableHTML(title, data, columns);
        printWindow.document.write(html);
        printWindow.document.close();
        printWindow.focus();
        
        setTimeout(function() {
            printWindow.print();
            printWindow.close();
        }, 250);
    };
    
    /**
     * Build printable HTML
     */
    this.buildPrintableHTML = function(title, data, columns) {
        var html = '<!DOCTYPE html><html><head><meta charset="UTF-8">';
        html += '<title>' + title + '</title>';
        html += '<style>';
        html += 'body { font-family: Arial, sans-serif; margin: 20px; }';
        html += 'h1 { text-align: center; margin-bottom: 20px; }';
        html += 'table { width: 100%; border-collapse: collapse; }';
        html += 'th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }';
        html += 'th { background-color: #4CAF50; color: white; }';
        html += 'tr:nth-child(even) { background-color: #f2f2f2; }';
        html += '@media print { body { margin: 0; } }';
        html += '</style></head><body>';
        html += '<h1>' + title + '</h1>';
        html += '<table>';
        
        // Header
        html += '<thead><tr>';
        columns.forEach(function(col) {
            html += '<th>' + col.label + '</th>';
        });
        html += '</tr></thead>';
        
        // Data
        html += '<tbody>';
        data.forEach(function(item) {
            html += '<tr>';
            columns.forEach(function(col) {
                var value = col.field.split('.').reduce(function(obj, key) {
                    return obj ? obj[key] : '';
                }, item);
                html += '<td>' + (value || '') + '</td>';
            });
            html += '</tr>';
        });
        html += '</tbody>';
        
        html += '</table></body></html>';
        return html;
    };
}]);

