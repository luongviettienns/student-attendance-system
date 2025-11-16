# verify-environment.ps1
# Script to verify backend services are running and database is seeded

param(
    [string]$GatewayUrl = "https://localhost:7033",
    [string]$AdminUrl = "http://localhost:5227"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Environment Verification Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allChecksPass = $true

# Function to test URL
function Test-ServiceUrl {
    param(
        [string]$Url,
        [string]$ServiceName
    )
    
    Write-Host "Checking $ServiceName at $Url..." -NoNewline
    
    try {
        # Skip SSL certificate validation for localhost
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $response = Invoke-WebRequest -Uri "$Url/health" -Method GET -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
        } else {
            # For PowerShell 5.1
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
            $response = Invoke-WebRequest -Uri "$Url/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
        }
        
        if ($response.StatusCode -eq 200) {
            Write-Host " OK RUNNING" -ForegroundColor Green
            return $true
        } else {
            Write-Host " UNEXPECTED STATUS: $($response.StatusCode)" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host " NOT ACCESSIBLE" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Check Gateway API
Write-Host "`n1. Backend Services Check" -ForegroundColor Yellow
Write-Host "----------------------------"
$gatewayRunning = Test-ServiceUrl -Url $GatewayUrl -ServiceName "Gateway API"
$adminRunning = Test-ServiceUrl -Url $AdminUrl -ServiceName "Admin API"

if (-not $gatewayRunning -or -not $adminRunning) {
    $allChecksPass = $false
    Write-Host "`nTo start backend services, run:" -ForegroundColor Yellow
    Write-Host "  .\start-system.ps1" -ForegroundColor Cyan
}

# Check Database Connection
Write-Host "`n2. Database Connection Check" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host "Checking SQL Server connection..." -NoNewline

try {
    $sqlCheck = sqlcmd -S "localhost\SQLEXPRESS" -d "EducationManagementDB" -Q "SELECT COUNT(*) as Count FROM Students" -h -1 -W
    
    if ($LASTEXITCODE -eq 0) {
        $studentCount = [int]$sqlCheck.Trim()
        Write-Host " CONNECTED" -ForegroundColor Green
        Write-Host "  Students in database: $studentCount"
        
        if ($studentCount -eq 0) {
            Write-Host "  WARNING: No students found. Database may not be seeded." -ForegroundColor Yellow
            $allChecksPass = $false
        }
    } else {
        Write-Host " QUERY FAILED" -ForegroundColor Red
        $allChecksPass = $false
    }
}
catch {
    Write-Host " CONNECTION FAILED" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    $allChecksPass = $false
    Write-Host "`nTo setup database, run:" -ForegroundColor Yellow
    Write-Host "  sqlcmd -S localhost\SQLEXPRESS -i SQL/00_ResetDatabase.sql" -ForegroundColor Cyan
    Write-Host "  sqlcmd -S localhost\SQLEXPRESS -i SQL/01_CreateTables.sql" -ForegroundColor Cyan
    Write-Host "  sqlcmd -S localhost\SQLEXPRESS -i SQL/03_SeedData.sql" -ForegroundColor Cyan
}

# Check VS Code REST Client Extension
Write-Host "`n3. VS Code REST Client Extension" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host "Checking if REST Client extension is installed..." -NoNewline

try {
    $extensions = code --list-extensions 2>$null
    if ($extensions -match "humao.rest-client") {
        Write-Host " INSTALLED" -ForegroundColor Green
    } else {
        Write-Host " NOT INSTALLED" -ForegroundColor Yellow
        Write-Host "`nTo install REST Client extension:" -ForegroundColor Yellow
        Write-Host "  1. Open VS Code" -ForegroundColor Cyan
        Write-Host "  2. Press Ctrl+Shift+X to open Extensions" -ForegroundColor Cyan
        Write-Host "  3. Search for REST Client by Huachao Mao" -ForegroundColor Cyan
        Write-Host "  4. Click Install" -ForegroundColor Cyan
        Write-Host "`nOr run: code --install-extension humao.rest-client" -ForegroundColor Cyan
    }
}
catch {
    Write-Host " UNABLE TO CHECK" -ForegroundColor Yellow
    Write-Host "  VS Code CLI may not be in PATH" -ForegroundColor Yellow
}

# Check Test Infrastructure
Write-Host "`n4. Test Infrastructure Check" -ForegroundColor Yellow
Write-Host "----------------------------"

$directories = @("test-suites", "test-data", "test-results", "scripts", "reports")
foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Write-Host "  OK $dir directory exists" -ForegroundColor Green
    } else {
        Write-Host "  MISSING $dir directory" -ForegroundColor Red
        $allChecksPass = $false
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allChecksPass) {
    Write-Host "SUCCESS: Environment is ready for testing!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "WARNING: Environment setup incomplete" -ForegroundColor Red
    Write-Host "Please fix the issues above before running tests." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    exit 1
}
