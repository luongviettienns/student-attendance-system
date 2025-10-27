# ============================================
# 🚀 SCRIPT KHỞI TẠO DATABASE TỰ ĐỘNG
# Hệ thống Quản lý Điểm danh Sinh viên
# ============================================

param(
    [string]$Server = "DESKTOP-2PQVVC6\SQLEXPRESS",
    [switch]$Reset,
    [switch]$Production,
    [switch]$UpdateOnly
)

# Colors
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Header
Write-Host ""
Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor $SuccessColor
Write-Host "║   🎓 EDUCATION MANAGEMENT - DATABASE SETUP    ║" -ForegroundColor $SuccessColor
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor $SuccessColor
Write-Host ""

# Check sqlcmd
Write-Host "🔍 Kiểm tra sqlcmd..." -ForegroundColor $InfoColor
try {
    $null = sqlcmd -?
    Write-Host "   ✅ sqlcmd found" -ForegroundColor $SuccessColor
} catch {
    Write-Host "   ❌ sqlcmd not found. Please install SQL Server Command Line Utilities" -ForegroundColor $ErrorColor
    exit 1
}

# Configuration
Write-Host "📋 Configuration:" -ForegroundColor $InfoColor
Write-Host "   Server: $Server" -ForegroundColor $InfoColor
Write-Host "   Mode: $(if ($Production) { 'PRODUCTION' } else { 'DEVELOPMENT' })" -ForegroundColor $(if ($Production) { $WarningColor } else { $InfoColor })
Write-Host "   Reset: $(if ($Reset) { 'YES ⚠️' } else { 'NO' })" -ForegroundColor $(if ($Reset) { $WarningColor } else { $InfoColor })
Write-Host ""

# Confirm in production
if ($Production -and -not $UpdateOnly) {
    Write-Host "⚠️  PRODUCTION MODE DETECTED!" -ForegroundColor $WarningColor
    $confirm = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "❌ Aborted by user" -ForegroundColor $ErrorColor
        exit 0
    }
}

# Reset (optional)
if ($Reset) {
    Write-Host "⚠️  RESET DATABASE - This will DELETE all data!" -ForegroundColor $WarningColor
    $confirm = Read-Host "Type 'DELETE ALL DATA' to confirm"
    if ($confirm -eq "DELETE ALL DATA") {
        Write-Host "   🗑️  Resetting database..." -ForegroundColor $WarningColor
        sqlcmd -S $Server -i 00_ResetData.sql -b
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Database reset complete" -ForegroundColor $SuccessColor
        } else {
            Write-Host "   ❌ Reset failed" -ForegroundColor $ErrorColor
            exit 1
        }
    } else {
        Write-Host "   ❌ Reset cancelled (wrong confirmation)" -ForegroundColor $ErrorColor
        exit 0
    }
    Write-Host ""
}

# Function to run SQL file
function Run-SQLFile {
    param(
        [string]$File,
        [string]$Description
    )
    
    Write-Host "📄 $Description..." -ForegroundColor $InfoColor
    
    if (-not (Test-Path $File)) {
        Write-Host "   ❌ File not found: $File" -ForegroundColor $ErrorColor
        return $false
    }
    
    $result = sqlcmd -S $Server -i $File -b 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Success" -ForegroundColor $SuccessColor
        return $true
    } else {
        Write-Host "   ❌ Failed" -ForegroundColor $ErrorColor
        Write-Host "   Error: $result" -ForegroundColor $ErrorColor
        return $false
    }
}

# Start timer
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Update Only mode
if ($UpdateOnly) {
    Write-Host "🔄 UPDATE MODE - Only running new/updated files" -ForegroundColor $InfoColor
    Write-Host ""
    
    $success = $true
    $success = $success -and (Run-SQLFile "06_RefreshTokens.sql" "Creating refresh tokens")
    $success = $success -and (Run-SQLFile "07_StoredProcedures_ErrorHandling.sql" "Adding error handling")
    $success = $success -and (Run-SQLFile "04_Indexes.sql" "Creating/updating indexes")
    
    Write-Host ""
    if ($success) {
        Write-Host "✅ UPDATE COMPLETED!" -ForegroundColor $SuccessColor
    } else {
        Write-Host "❌ UPDATE FAILED!" -ForegroundColor $ErrorColor
        exit 1
    }
    
    $stopwatch.Stop()
    Write-Host "⏱️  Time: $($stopwatch.Elapsed.TotalSeconds) seconds" -ForegroundColor $InfoColor
    exit 0
}

# Full setup
Write-Host "🏗️  FULL SETUP - Creating database from scratch" -ForegroundColor $InfoColor
Write-Host ""

$totalSteps = if ($Production) { 6 } else { 7 }
$currentStep = 0
$allSuccess = $true

# Step 1: Create Tables
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "01_CreateTables.sql" "Creating tables (19 tables)")

# Step 2: Create Stored Procedures
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "02_StoredProcedures.sql" "Creating stored procedures (90+ procedures)")

# Step 3: Refresh Tokens
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "06_RefreshTokens.sql" "Creating refresh token procedures")

# Step 4: Error Handling
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "07_StoredProcedures_ErrorHandling.sql" "Adding error handling")

# Step 5: Indexes
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "04_Indexes.sql" "Creating indexes (25+ indexes)")

# Step 6: Views
$currentStep++
Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
$allSuccess = $allSuccess -and (Run-SQLFile "05_Views.sql" "Creating views (6 views)")

# Step 7: Seed Data (Development only)
if (-not $Production) {
    $currentStep++
    Write-Host "[$currentStep/$totalSteps] " -NoNewline -ForegroundColor $InfoColor
    $allSuccess = $allSuccess -and (Run-SQLFile "03_SeedData.sql" "Inserting sample data")
}

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor $InfoColor

# Verification
Write-Host ""
Write-Host "🔍 VERIFICATION" -ForegroundColor $InfoColor
Write-Host ""

$verifyQuery = @"
SELECT 'Tables' AS Type, COUNT(*) AS Count 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'EducationManagement' AND TABLE_TYPE = 'BASE TABLE'
UNION ALL
SELECT 'Stored Procedures', COUNT(*) 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_CATALOG = 'EducationManagement'
UNION ALL
SELECT 'Indexes', COUNT(*) 
FROM sys.indexes i INNER JOIN sys.tables t ON i.object_id = t.object_id 
WHERE t.is_ms_shipped = 0 AND i.type > 0
UNION ALL
SELECT 'Views', COUNT(*) 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_CATALOG = 'EducationManagement';
"@

sqlcmd -S $Server -Q $verifyQuery -h -1

Write-Host ""

# Final result
$stopwatch.Stop()

if ($allSuccess) {
    Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor $SuccessColor
    Write-Host "║            ✅ SETUP COMPLETED!                 ║" -ForegroundColor $SuccessColor
    Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor $SuccessColor
    Write-Host ""
    Write-Host "📊 Summary:" -ForegroundColor $SuccessColor
    Write-Host "   ✅ 19 Tables created" -ForegroundColor $SuccessColor
    Write-Host "   ✅ 95+ Stored Procedures created" -ForegroundColor $SuccessColor
    Write-Host "   ✅ 25+ Indexes created" -ForegroundColor $SuccessColor
    Write-Host "   ✅ 6 Views created" -ForegroundColor $SuccessColor
    if (-not $Production) {
        Write-Host "   ✅ Sample data inserted" -ForegroundColor $SuccessColor
    }
    Write-Host ""
    Write-Host "⏱️  Total time: $($stopwatch.Elapsed.TotalSeconds) seconds" -ForegroundColor $InfoColor
    Write-Host ""
    
    if (-not $Production) {
        Write-Host "🔑 Login credentials (Development):" -ForegroundColor $InfoColor
        Write-Host "   Email: admin@example.com" -ForegroundColor $InfoColor
        Write-Host "   Password: Admin@123" -ForegroundColor $InfoColor
        Write-Host ""
    }
    
    Write-Host "📚 Next steps:" -ForegroundColor $InfoColor
    Write-Host "   1. Start Redis server" -ForegroundColor $InfoColor
    Write-Host "   2. Run backend API: dotnet run" -ForegroundColor $InfoColor
    Write-Host "   3. Start frontend" -ForegroundColor $InfoColor
    Write-Host "   4. Test login" -ForegroundColor $InfoColor
    Write-Host ""
    
} else {
    Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor $ErrorColor
    Write-Host "║            ❌ SETUP FAILED!                    ║" -ForegroundColor $ErrorColor
    Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor $ErrorColor
    Write-Host ""
    Write-Host "⏱️  Failed after: $($stopwatch.Elapsed.TotalSeconds) seconds" -ForegroundColor $InfoColor
    Write-Host ""
    Write-Host "🔍 Check the error messages above" -ForegroundColor $ErrorColor
    Write-Host "📚 See DATABASE_SETUP_GUIDE.md for troubleshooting" -ForegroundColor $InfoColor
    Write-Host ""
    exit 1
}

