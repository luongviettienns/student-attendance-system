# Run-All-Stored-Procedures.ps1
# Script PowerShell để chạy tất cả các file Stored Procedures theo đúng thứ tự

param(
    [string]$Server = "localhost",
    [string]$Database = "EducationManagement",
    [string]$Username = "",
    [string]$Password = "",
    [switch]$UseIntegratedSecurity = $true
)

# Danh sách các file SP cần chạy theo thứ tự
$spFiles = @(
    "02a_SP_Users.sql",
    "02b_SP_Organization.sql",
    "02c_SP_Academic.sql",
    "02d_SP_Students.sql",
    "02e_SP_Lecturers.sql",
    "02f_SP_Subjects.sql",
    "02g_SP_Classes.sql",
    "02h_SP_Attendance.sql",
    "02i_SP_Grades.sql",
    "02j_SP_System.sql",
    "02k_SP_Timetable.sql",
    "02l_SP_Administrative.sql"
)

# Xây dựng connection string
$connectionString = "Server=$Server;Database=$Database;"
if ($UseIntegratedSecurity) {
    $connectionString += "Integrated Security=True;"
} else {
    $connectionString += "User Id=$Username;Password=$Password;"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CHAY TAT CA STORED PROCEDURES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Server: $Server" -ForegroundColor Yellow
Write-Host "Database: $Database" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Lấy đường dẫn thư mục script
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlPath = Join-Path $scriptPath "SQL"

# Kiểm tra thư mục SQL có tồn tại không
if (-not (Test-Path $sqlPath)) {
    Write-Host "LOI: Khong tim thay thu muc SQL!" -ForegroundColor Red
    exit 1
}

$successCount = 0
$failCount = 0
$totalFiles = $spFiles.Count

foreach ($file in $spFiles) {
    $filePath = Join-Path $sqlPath $file
    
    if (-not (Test-Path $filePath)) {
        Write-Host "[$($successCount + $failCount + 1)/$totalFiles] ❌ Khong tim thay: $file" -ForegroundColor Red
        $failCount++
        continue
    }
    
    Write-Host "[$($successCount + $failCount + 1)/$totalFiles] ⏳ Dang chay: $file" -ForegroundColor Yellow
    
    try {
        # Đọc nội dung file SQL
        $sqlContent = Get-Content $filePath -Raw -Encoding UTF8
        
        # Chạy SQL script
        if ($UseIntegratedSecurity) {
            Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $sqlContent -ErrorAction Stop | Out-Null
        } else {
            Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Username $Username -Password $Password -Query $sqlContent -ErrorAction Stop | Out-Null
        }
        
        Write-Host "        ✅ Hoan thanh: $file" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "        ❌ LOI: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KET QUA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tong so file: $totalFiles" -ForegroundColor White
Write-Host "Thanh cong: $successCount" -ForegroundColor Green
Write-Host "That bai: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if ($failCount -eq 0) {
    Write-Host "🎉 Hoan thanh! Tat ca cac SP da duoc tao thanh cong!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Co loi xay ra! Vui long kiem tra lai." -ForegroundColor Yellow
    exit 1
}

