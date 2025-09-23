# PowerShell Script để setup Database cho SimpleUserAPI
# Chạy script này để tự động tạo database và cấu hình

param(
    [Parameter(Mandatory=$false)]
    [string]$ServerName = "localhost\SQLEXPRESS",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseName = "SimpleUserDB",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$UseWindowsAuth = $true
)

Write-Host "🚀 Bắt đầu setup Database cho SimpleUserAPI" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Yellow

# Kiểm tra SQL Server
Write-Host "🔍 Kiểm tra SQL Server..." -ForegroundColor Cyan
try {
    $sqlServer = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue
    if ($sqlServer) {
        Write-Host "✅ SQL Server đang chạy: $($sqlServer.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ SQL Server không được tìm thấy. Vui lòng cài đặt SQL Server." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Lỗi khi kiểm tra SQL Server: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Tạo connection string
Write-Host "🔧 Tạo connection string..." -ForegroundColor Cyan
if ($UseWindowsAuth -and [string]::IsNullOrEmpty($Username)) {
    $connectionString = "Server=$ServerName;Database=$DatabaseName;Trusted_Connection=True;TrustServerCertificate=True;"
    Write-Host "✅ Sử dụng Windows Authentication" -ForegroundColor Green
} else {
    $connectionString = "Server=$ServerName;Database=$DatabaseName;User Id=$Username;Password=$Password;TrustServerCertificate=True;"
    Write-Host "✅ Sử dụng SQL Server Authentication" -ForegroundColor Green
}

Write-Host "📝 Connection String: $connectionString" -ForegroundColor Yellow

# Chạy script SQL
Write-Host "📁 Chạy script tạo database..." -ForegroundColor Cyan
$scriptPath = Join-Path $PSScriptRoot "SimpleUserDB.sql"

if (Test-Path $scriptPath) {
    Write-Host "✅ Tìm thấy script: $scriptPath" -ForegroundColor Green
    
    try {
        if ($UseWindowsAuth -and [string]::IsNullOrEmpty($Username)) {
            # Windows Authentication
            $result = sqlcmd -S $ServerName -i $scriptPath -h -1 -W
        } else {
            # SQL Server Authentication
            $result = sqlcmd -S $ServerName -U $Username -P $Password -i $scriptPath -h -1 -W
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Script database chạy thành công!" -ForegroundColor Green
        } else {
            Write-Host "❌ Lỗi khi chạy script database" -ForegroundColor Red
            Write-Host "Output: $result" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Lỗi khi chạy script: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Không tìm thấy script: $scriptPath" -ForegroundColor Red
    exit 1
}

# Test kết nối database
Write-Host "🔗 Test kết nối database..." -ForegroundColor Cyan
try {
    $testQuery = "SELECT COUNT(*) as UserCount FROM users WHERE is_active = 1"
    
    if ($UseWindowsAuth -and [string]::IsNullOrEmpty($Username)) {
        $result = sqlcmd -S $ServerName -d $DatabaseName -Q $testQuery -h -1 -W
    } else {
        $result = sqlcmd -S $ServerName -d $DatabaseName -U $Username -P $Password -Q $testQuery -h -1 -W
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kết nối database thành công!" -ForegroundColor Green
        Write-Host "📊 Kết quả: $result" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Lỗi khi test kết nối database" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Lỗi khi test kết nối: $($_.Exception.Message)" -ForegroundColor Red
}

# Cập nhật file cấu hình
Write-Host "📝 Cập nhật file cấu hình..." -ForegroundColor Cyan
$configFile = Join-Path (Split-Path $PSScriptRoot -Parent) "appsettings.json"

if (Test-Path $configFile) {
    Write-Host "✅ Tìm thấy file cấu hình: $configFile" -ForegroundColor Green
    
    try {
        # Đọc file JSON
        $config = Get-Content $configFile | ConvertFrom-Json
        
        # Cập nhật connection strings
        $config.ConnectionStrings.DefaultConnection = $connectionString
        $config.ConnectionStrings.SqlServer = $connectionString
        
        if ($UseWindowsAuth -and [string]::IsNullOrEmpty($Username)) {
            $config.ConnectionStrings.LocalDB = "Server=(localdb)\mssqllocaldb;Database=$DatabaseName;Trusted_Connection=True;TrustServerCertificate=True;"
        } else {
            $config.ConnectionStrings.SqlServerWithPassword = $connectionString
        }
        
        # Lưu file
        $config | ConvertTo-Json -Depth 10 | Set-Content $configFile
        Write-Host "✅ Đã cập nhật file cấu hình" -ForegroundColor Green
    } catch {
        Write-Host "❌ Lỗi khi cập nhật file cấu hình: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Không tìm thấy file cấu hình: $configFile" -ForegroundColor Red
}

# Build project
Write-Host "🔨 Build project..." -ForegroundColor Cyan
try {
    $projectPath = Split-Path $PSScriptRoot -Parent
    Set-Location $projectPath
    dotnet build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build project thành công!" -ForegroundColor Green
    } else {
        Write-Host "❌ Build project thất bại" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Lỗi khi build project: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=================================================" -ForegroundColor Yellow
Write-Host "🎉 Hoàn thành setup Database!" -ForegroundColor Green
Write-Host "📋 Thông tin cấu hình:" -ForegroundColor Cyan
Write-Host "   - Server: $ServerName" -ForegroundColor White
Write-Host "   - Database: $DatabaseName" -ForegroundColor White
Write-Host "   - Authentication: $(if($UseWindowsAuth) {'Windows'} else {'SQL Server'})" -ForegroundColor White
Write-Host "   - Config File: $configFile" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Để chạy ứng dụng:" -ForegroundColor Yellow
Write-Host "   dotnet run" -ForegroundColor White
Write-Host ""
Write-Host "📖 Xem hướng dẫn chi tiết: README_Database_Setup.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Test API:" -ForegroundColor Yellow
Write-Host "   - Swagger UI: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "   - Health Check: http://localhost:5000/health" -ForegroundColor White
Write-Host "   - API Endpoints: http://localhost:5000/api/user" -ForegroundColor White


