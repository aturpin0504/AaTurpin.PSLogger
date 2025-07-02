function Write-LogEntry {
    <#
    .SYNOPSIS
        Writes a thread-safe log entry to the specified log file.
    
    .DESCRIPTION
        Provides thread-safe logging with mutex synchronization and basic retry logic.
        Simplified version with essential features only.
    
    .PARAMETER LogPath
        The path to the log file where the entry will be written.
    
    .PARAMETER Level
        The log level for this entry. Valid values are: Debug, Information, Warning, Error, Critical.
    
    .PARAMETER Message
        The log message to write.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retry attempts. Default is 3.
    
    .PARAMETER RetryDelayMs
        Delay between retries in milliseconds. Default is 100ms.
    
    .EXAMPLE
        Write-LogEntry -LogPath "C:\Logs\app.log" -Level "Information" -Message "Application started"
    
    .EXAMPLE
        try { 
            Get-Item "nonexistent" 
        } catch { 
            Write-LogEntry -LogPath "C:\Logs\app.log" -Level "Error" -Message "File operation failed" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Debug", "Information", "Warning", "Error", "Critical")]
        [string]$Level,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    try {
        # Ensure log directory exists
        $logDir = Split-Path -Path $LogPath -Parent
        if ($logDir -and -not (Test-Path -Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        
        # Create log entry
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $logEntry = "[$timestamp] [$Level] $Message"
        
        # Add exception details if provided
        if ($Exception) {
            $logEntry += "`n  Exception: $($Exception.GetType().Name): $($Exception.Message)"
        }
        
        # Thread-safe file writing with retry
        $mutexName = "LogMutex_" + ($LogPath -replace '[\\/:*?"<>|]', '_')
        $mutex = $null
        $success = $false
        $retryCount = 0
        
        while (-not $success -and $retryCount -le $MaxRetries) {
            try {
                $mutex = New-Object System.Threading.Mutex($false, $mutexName)
                
                if ($mutex.WaitOne(5000)) {
                    try {
                        [System.IO.File]::AppendAllText($LogPath, $logEntry + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
                        $success = $true
                    }
                    finally {
                        $mutex.ReleaseMutex()
                    }
                }
                else {
                    throw "Mutex timeout"
                }
            }
            catch {
                $retryCount++
                if ($retryCount -le $MaxRetries) {
                    Start-Sleep -Milliseconds $RetryDelayMs
                }
                else {
                    throw "Failed to write to log file after $MaxRetries retries: $($_.Exception.Message)"
                }
            }
            finally {
                if ($mutex) {
                    $mutex.Dispose()
                    $mutex = $null
                }
            }
        }
        
        # Write to console based on level
        switch ($Level) {
            "Error" { Write-Error $Message -ErrorAction Continue }
            "Critical" { Write-Error $Message -ErrorAction Continue }
            "Warning" { Write-Warning $Message }
            "Debug" { Write-Debug $Message }
            "Information" { Write-Verbose $Message }
            default { Write-Host $Message }
        }
    }
    catch {
        Write-Error "Failed to write to log file '$LogPath': $($_.Exception.Message)"
    }
}

function Write-LogDebug {
    <#
    .SYNOPSIS
        Writes a debug log entry to the specified log file.
    
    .DESCRIPTION
        Helper function for writing debug-level log entries with optional exception details.
    
    .PARAMETER LogPath
        The path to the log file.
    
    .PARAMETER Message
        The debug message to log.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retries for thread-safe file writing (default: 3).
    
    .PARAMETER RetryDelayMs
        Delay in milliseconds between retries (default: 100).
    
    .EXAMPLE
        Write-LogDebug -LogPath "C:\Logs\app.log" -Message "Processing item: $itemName"
    
    .EXAMPLE
        try { 
            Get-Item "debug-file" 
        } catch { 
            Write-LogDebug -LogPath "C:\Logs\app.log" -Message "Debug operation failed" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    Write-LogEntry -LogPath $LogPath -Level "Debug" -Message $Message -Exception $Exception -MaxRetries $MaxRetries -RetryDelayMs $RetryDelayMs
}

function Write-LogInfo {
    <#
    .SYNOPSIS
        Writes an informational log entry to the specified log file.
    
    .DESCRIPTION
        Helper function for writing information-level log entries with optional exception details.
    
    .PARAMETER LogPath
        The path to the log file.
    
    .PARAMETER Message
        The informational message to log.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retries for thread-safe file writing (default: 3).
    
    .PARAMETER RetryDelayMs
        Delay in milliseconds between retries (default: 100).
    
    .EXAMPLE
        Write-LogInfo -LogPath "C:\Logs\app.log" -Message "Application started successfully"
    
    .EXAMPLE
        try { 
            Start-Process "notepad" 
        } catch { 
            Write-LogInfo -LogPath "C:\Logs\app.log" -Message "Process start completed with issues" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    Write-LogEntry -LogPath $LogPath -Level "Information" -Message $Message -Exception $Exception -MaxRetries $MaxRetries -RetryDelayMs $RetryDelayMs
}

function Write-LogWarning {
    <#
    .SYNOPSIS
        Writes a warning log entry to the specified log file.
    
    .DESCRIPTION
        Helper function for writing warning-level log entries with optional exception details.
    
    .PARAMETER LogPath
        The path to the log file.
    
    .PARAMETER Message
        The warning message to log.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retries for thread-safe file writing (default: 3).
    
    .PARAMETER RetryDelayMs
        Delay in milliseconds between retries (default: 100).
    
    .EXAMPLE
        Write-LogWarning -LogPath "C:\Logs\app.log" -Message "Disk space is running low"
    
    .EXAMPLE
        try { 
            Remove-Item "temp-file" 
        } catch { 
            Write-LogWarning -LogPath "C:\Logs\app.log" -Message "Temporary file cleanup failed" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    Write-LogEntry -LogPath $LogPath -Level "Warning" -Message $Message -Exception $Exception -MaxRetries $MaxRetries -RetryDelayMs $RetryDelayMs
}

function Write-LogError {
    <#
    .SYNOPSIS
        Writes an error log entry to the specified log file.
    
    .DESCRIPTION
        Helper function for writing error-level log entries with optional exception details.
    
    .PARAMETER LogPath
        The path to the log file.
    
    .PARAMETER Message
        The error message to log.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retries for thread-safe file writing (default: 3).
    
    .PARAMETER RetryDelayMs
        Delay in milliseconds between retries (default: 100).
    
    .EXAMPLE
        Write-LogError -LogPath "C:\Logs\app.log" -Message "Database connection failed"
    
    .EXAMPLE
        try { 
            Get-Item "nonexistent" 
        } catch { 
            Write-LogError -LogPath "C:\Logs\app.log" -Message "File operation failed" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    Write-LogEntry -LogPath $LogPath -Level "Error" -Message $Message -Exception $Exception -MaxRetries $MaxRetries -RetryDelayMs $RetryDelayMs
}

function Write-LogCritical {
    <#
    .SYNOPSIS
        Writes a critical log entry to the specified log file.
    
    .DESCRIPTION
        Helper function for writing critical-level log entries with optional exception details.
    
    .PARAMETER LogPath
        The path to the log file.
    
    .PARAMETER Message
        The critical message to log.
    
    .PARAMETER Exception
        Optional exception object to include in the log entry.
    
    .PARAMETER MaxRetries
        Maximum number of retries for thread-safe file writing (default: 3).
    
    .PARAMETER RetryDelayMs
        Delay in milliseconds between retries (default: 100).
    
    .EXAMPLE
        Write-LogCritical -LogPath "C:\Logs\app.log" -Message "System is shutting down unexpectedly"
    
    .EXAMPLE
        try { 
            Stop-Computer -Force 
        } catch { 
            Write-LogCritical -LogPath "C:\Logs\app.log" -Message "Emergency shutdown failed" -Exception $_.Exception 
        }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Exception]$Exception = $null,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,
        
        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 100
    )
    
    Write-LogEntry -LogPath $LogPath -Level "Critical" -Message $Message -Exception $Exception -MaxRetries $MaxRetries -RetryDelayMs $RetryDelayMs
}

Export-ModuleMember -Function Write-LogDebug, Write-LogInfo, Write-LogWarning, Write-LogError, Write-LogCritical