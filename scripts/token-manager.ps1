# ============================================================
# Token Manager Script
# ============================================================
# Purpose: Manage authentication tokens for API testing
# - Login and store tokens for different roles
# - Refresh tokens when expired
# - Provide token reuse mechanism
# ============================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('login', 'refresh', 'get', 'clear', 'status')]
    [string]$Action = 'status',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('admin', 'lecturer', 'student_k21_01', 'student_k21_02', 'student_k22_01', 'student_k23_01', 'student_k24_01', 'all')]
    [string]$Role = 'all',
    
    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = 'http://localhost:5227'
)

# Configuration
$TokenFile = Join-Path $PSScriptRoot "..\test-data\tokens.json"
$ConfigFile = Join-Path $PSScriptRoot "..\test-config.json"

# Load configuration
function Load-Config {
    if (Test-Path $ConfigFile) {
        $config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
        return $config
    }
    Write-Error "Configuration file not found: $ConfigFile"
    exit 1
}

# Load tokens from file
function Load-Tokens {
    if (Test-Path $TokenFile) {
        $tokens = Get-Content $TokenFile -Raw | ConvertFrom-Json
        return $tokens
    }
    Write-Error "Token file not found: $TokenFile"
    exit 1
}

# Save tokens to file
function Save-Tokens {
    param($TokenData)
    
    $TokenData.lastUpdated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    $json = $TokenData | ConvertTo-Json -Depth 10
    Set-Content -Path $TokenFile -Value $json -Encoding UTF8
    Write-Host "✓ Tokens saved to $TokenFile" -ForegroundColor Green
}

# Login and get token
function Login-User {
    param(
        [string]$Username,
        [string]$Password,
        [string]$BaseUrl
    )
    
    $loginUrl = "$BaseUrl/api-edu/auth/login"
    $body = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json
    
    try {
        Write-Host "Logging in as $Username..." -ForegroundColor Cyan
        
        $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        
        if ($response.token) {
            Write-Host "✓ Login successful for $Username" -ForegroundColor Green
            
            # Calculate expiration time (assuming 120 minutes from token response)
            $expiresAt = (Get-Date).AddMinutes(120).ToString("yyyy-MM-ddTHH:mm:ss")
            
            return @{
                accessToken = $response.token
                refreshToken = $response.refreshToken
                expiresAt = $expiresAt
                user = $response.user
            }
        } else {
            Write-Host "✗ Login failed for $Username - No token in response" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "✗ Login failed for $Username" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Refresh token
function Refresh-Token {
    param(
        [string]$RefreshToken,
        [string]$BaseUrl
    )
    
    $refreshUrl = "$BaseUrl/api-edu/auth/refresh"
    $body = @{
        refreshToken = $RefreshToken
    } | ConvertTo-Json
    
    try {
        Write-Host "Refreshing token..." -ForegroundColor Cyan
        
        $response = Invoke-RestMethod -Uri $refreshUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        
        if ($response.token) {
            Write-Host "✓ Token refreshed successfully" -ForegroundColor Green
            
            $expiresAt = (Get-Date).AddMinutes(120).ToString("yyyy-MM-ddTHH:mm:ss")
            
            return @{
                accessToken = $response.token
                refreshToken = $response.refreshToken
                expiresAt = $expiresAt
            }
        } else {
            Write-Host "✗ Token refresh failed - No token in response" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "✗ Token refresh failed" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Check if token is expired
function Test-TokenExpired {
    param([string]$ExpiresAt)
    
    if ([string]::IsNullOrEmpty($ExpiresAt)) {
        return $true
    }
    
    $expiryDate = [DateTime]::Parse($ExpiresAt)
    $now = Get-Date
    
    # Consider token expired if less than 5 minutes remaining
    return ($expiryDate.AddMinutes(-5) -lt $now)
}

# Get credentials for role
function Get-Credentials {
    param(
        [string]$Role,
        [object]$Config
    )
    
    switch ($Role) {
        'admin' {
            return @{
                username = $Config.testAccounts.admin.username
                password = $Config.testAccounts.admin.password
            }
        }
        'lecturer' {
            return @{
                username = $Config.testAccounts.lecturer.username
                password = $Config.testAccounts.lecturer.password
            }
        }
        'student_k21_01' {
            return @{
                username = 'student_k21_01'
                password = 'password123'
            }
        }
        'student_k21_02' {
            return @{
                username = 'student_k21_02'
                password = 'password123'
            }
        }
        'student_k22_01' {
            return @{
                username = 'student_k22_01'
                password = 'password123'
            }
        }
        'student_k23_01' {
            return @{
                username = 'student_k23_01'
                password = 'password123'
            }
        }
        'student_k24_01' {
            return @{
                username = 'student_k24_01'
                password = 'password123'
            }
        }
        default {
            return $null
        }
    }
}

# Main action handlers
switch ($Action) {
    'login' {
        Write-Host "`n=== Token Manager: Login ===" -ForegroundColor Yellow
        Write-Host "Base URL: $BaseUrl`n" -ForegroundColor Gray
        
        $config = Load-Config
        $tokenData = Load-Tokens
        
        $roles = if ($Role -eq 'all') {
            @('admin', 'lecturer', 'student_k21_01', 'student_k21_02', 'student_k22_01', 'student_k23_01', 'student_k24_01')
        } else {
            @($Role)
        }
        
        foreach ($r in $roles) {
            $creds = Get-Credentials -Role $r -Config $config
            
            if ($creds) {
                $result = Login-User -Username $creds.username -Password $creds.password -BaseUrl $BaseUrl
                
                if ($result) {
                    $tokenData.tokens.$r.accessToken = $result.accessToken
                    $tokenData.tokens.$r.refreshToken = $result.refreshToken
                    $tokenData.tokens.$r.expiresAt = $result.expiresAt
                }
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        Save-Tokens -TokenData $tokenData
        Write-Host "`n✓ Login process completed" -ForegroundColor Green
    }
    
    'refresh' {
        Write-Host "`n=== Token Manager: Refresh ===" -ForegroundColor Yellow
        Write-Host "Base URL: $BaseUrl`n" -ForegroundColor Gray
        
        $tokenData = Load-Tokens
        
        $roles = if ($Role -eq 'all') {
            @('admin', 'lecturer', 'student_k21_01', 'student_k21_02', 'student_k22_01', 'student_k23_01', 'student_k24_01')
        } else {
            @($Role)
        }
        
        foreach ($r in $roles) {
            $refreshToken = $tokenData.tokens.$r.refreshToken
            
            if ($refreshToken) {
                Write-Host "Refreshing token for $r..." -ForegroundColor Cyan
                $result = Refresh-Token -RefreshToken $refreshToken -BaseUrl $BaseUrl
                
                if ($result) {
                    $tokenData.tokens.$r.accessToken = $result.accessToken
                    $tokenData.tokens.$r.refreshToken = $result.refreshToken
                    $tokenData.tokens.$r.expiresAt = $result.expiresAt
                }
            } else {
                Write-Host "✗ No refresh token found for $r" -ForegroundColor Red
            }
            
            Start-Sleep -Milliseconds 500
        }
        
        Save-Tokens -TokenData $tokenData
        Write-Host "`n✓ Refresh process completed" -ForegroundColor Green
    }
    
    'get' {
        $tokenData = Load-Tokens
        
        if ($Role -eq 'all') {
            Write-Host "`n=== All Tokens ===" -ForegroundColor Yellow
            $tokenData.tokens.PSObject.Properties | ForEach-Object {
                $roleName = $_.Name
                $token = $_.Value.accessToken
                $expires = $_.Value.expiresAt
                $isExpired = Test-TokenExpired -ExpiresAt $expires
                
                Write-Host "`n$roleName :" -ForegroundColor Cyan
                if ($token) {
                    Write-Host "  Token: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor Gray
                    Write-Host "  Expires: $expires" -ForegroundColor Gray
                    if ($isExpired) {
                        Write-Host "  Status: EXPIRED" -ForegroundColor Red
                    } else {
                        Write-Host "  Status: VALID" -ForegroundColor Green
                    }
                } else {
                    Write-Host "  Status: NO TOKEN" -ForegroundColor Red
                }
            }
        } else {
            $token = $tokenData.tokens.$Role.accessToken
            if ($token) {
                Write-Host $token
            } else {
                Write-Host "No token found for role: $Role" -ForegroundColor Red
                exit 1
            }
        }
    }
    
    'clear' {
        Write-Host "`n=== Token Manager: Clear ===" -ForegroundColor Yellow
        
        $tokenData = Load-Tokens
        
        $roles = if ($Role -eq 'all') {
            @('admin', 'lecturer', 'student_k21_01', 'student_k21_02', 'student_k22_01', 'student_k23_01', 'student_k24_01')
        } else {
            @($Role)
        }
        
        foreach ($r in $roles) {
            $tokenData.tokens.$r.accessToken = $null
            $tokenData.tokens.$r.refreshToken = $null
            $tokenData.tokens.$r.expiresAt = $null
            Write-Host "✓ Cleared tokens for $r" -ForegroundColor Green
        }
        
        Save-Tokens -TokenData $tokenData
        Write-Host "`n✓ Clear process completed" -ForegroundColor Green
    }
    
    'status' {
        Write-Host "`n=== Token Manager: Status ===" -ForegroundColor Yellow
        
        $tokenData = Load-Tokens
        
        Write-Host "`nLast Updated: $($tokenData.lastUpdated)" -ForegroundColor Gray
        Write-Host "`nToken Status:" -ForegroundColor Cyan
        Write-Host ("=" * 80) -ForegroundColor Gray
        Write-Host ("{0,-20} {1,-15} {2,-25} {3,-15}" -f "Role", "Has Token", "Expires At", "Status") -ForegroundColor White
        Write-Host ("=" * 80) -ForegroundColor Gray
        
        $tokenData.tokens.PSObject.Properties | ForEach-Object {
            $roleName = $_.Name
            $hasToken = if ($_.Value.accessToken) { "Yes" } else { "No" }
            $expires = if ($_.Value.expiresAt) { $_.Value.expiresAt } else { "N/A" }
            $isExpired = Test-TokenExpired -ExpiresAt $_.Value.expiresAt
            
            $status = if (-not $_.Value.accessToken) {
                "NO TOKEN"
            } elseif ($isExpired) {
                "EXPIRED"
            } else {
                "VALID"
            }
            
            $statusColor = switch ($status) {
                "VALID" { "Green" }
                "EXPIRED" { "Yellow" }
                "NO TOKEN" { "Red" }
            }
            
            Write-Host ("{0,-20} {1,-15} {2,-25} " -f $roleName, $hasToken, $expires) -NoNewline
            Write-Host $status -ForegroundColor $statusColor
        }
        
        Write-Host ("=" * 80) -ForegroundColor Gray
        Write-Host "`nUsage:" -ForegroundColor Cyan
        Write-Host "  Login all:     .\scripts\token-manager.ps1 -Action login -Role all" -ForegroundColor Gray
        Write-Host "  Login single:  .\scripts\token-manager.ps1 -Action login -Role admin" -ForegroundColor Gray
        Write-Host "  Refresh all:   .\scripts\token-manager.ps1 -Action refresh -Role all" -ForegroundColor Gray
        Write-Host "  Get token:     .\scripts\token-manager.ps1 -Action get -Role admin" -ForegroundColor Gray
        Write-Host "  Clear all:     .\scripts\token-manager.ps1 -Action clear -Role all" -ForegroundColor Gray
    }
}

Write-Host ""
