# AaTurpin.PSLogger

A lightweight, thread-safe PowerShell logging module that provides structured logging with multiple severity levels and exception handling.

## Features

- **Thread-safe logging** with mutex synchronization
- **Multiple log levels**: Debug, Information, Warning, Error, Critical
- **Exception handling** with detailed exception information
- **Automatic retry logic** for file operations
- **Console output** based on log level
- **Automatic directory creation** for log files
- **UTF-8 encoding** support
- **Helper functions** for each log level

## Installation

### From NuGet.org
First, register NuGet.org as a PowerShell repository source if it's not already configured:

```powershell
# Register NuGet.org as a PowerShell repository
Register-PSRepository -Name "NuGet" -SourceLocation "https://www.nuget.org/api/v2" -InstallationPolicy Trusted

# Install the module
Install-Module -Name AaTurpin.PSLogger -Repository NuGet -Scope CurrentUser
```

### Alternative Installation (if NuGet repo already exists)
```powershell
Install-Module -Name AaTurpin.PSLogger -Repository NuGet -Scope CurrentUser
```

### Manual Installation
1. Download the module files
2. Copy to your PowerShell modules directory:
   - User scope: `$env:USERPROFILE\Documents\PowerShell\Modules\AaTurpin.PSLogger\`
   - System scope: `$env:ProgramFiles\PowerShell\Modules\AaTurpin.PSLogger\`

## Quick Start

```powershell
# Import the module
Import-Module AaTurpin.PSLogger

# Basic logging
Write-LogInfo -LogPath "C:\Logs\app.log" -Message "Application started"
Write-LogWarning -LogPath "C:\Logs\app.log" -Message "Low disk space detected"
Write-LogError -LogPath "C:\Logs\app.log" -Message "Database connection failed"

# Logging with exception handling
try {
    Get-Item "nonexistent-file.txt"
} catch {
    Write-LogError -LogPath "C:\Logs\app.log" -Message "File operation failed" -Exception $_.Exception
}
```

## Functions

### Core Function

#### `Write-LogEntry`
The main logging function that all helper functions use internally.

**Parameters:**
- `LogPath` (required) - Path to the log file
- `Level` (required) - Log level: Debug, Information, Warning, Error, Critical
- `Message` (required) - The message to log
- `Exception` (optional) - Exception object to include
- `MaxRetries` (optional) - Maximum retry attempts (default: 3)
- `RetryDelayMs` (optional) - Delay between retries in milliseconds (default: 100)

### Helper Functions

All helper functions share the same parameters except for the `Level`, which is pre-set:

#### `Write-LogDebug`
Writes debug-level log entries. Useful for detailed troubleshooting information.

```powershell
Write-LogDebug -LogPath "C:\Logs\debug.log" -Message "Processing user: $username"
```

#### `Write-LogInfo`
Writes informational log entries for general application flow.

```powershell
Write-LogInfo -LogPath "C:\Logs\app.log" -Message "Service started successfully"
```

#### `Write-LogWarning`
Writes warning-level entries for non-critical issues.

```powershell
Write-LogWarning -LogPath "C:\Logs\app.log" -Message "Configuration file not found, using defaults"
```

#### `Write-LogError`
Writes error-level entries for recoverable errors.

```powershell
Write-LogError -LogPath "C:\Logs\app.log" -Message "Failed to connect to database" -Exception $_.Exception
```

#### `Write-LogCritical`
Writes critical-level entries for severe errors that may cause application termination.

```powershell
Write-LogCritical -LogPath "C:\Logs\app.log" -Message "Out of memory - shutting down"
```

## Usage Examples

### Basic Logging
```powershell
# Simple message logging
Write-LogInfo -LogPath "C:\Logs\myapp.log" -Message "Application initialized"
Write-LogWarning -LogPath "C:\Logs\myapp.log" -Message "Memory usage at 80%"
```

### Exception Logging
```powershell
try {
    # Some operation that might fail
    Invoke-RestMethod -Uri "https://api.example.com/data"
} catch {
    Write-LogError -LogPath "C:\Logs\api.log" -Message "API call failed" -Exception $_.Exception
}
```

### Custom Retry Configuration
```powershell
# Increase retries and delay for high-contention scenarios
Write-LogInfo -LogPath "C:\Logs\busy.log" -Message "Processing batch" -MaxRetries 5 -RetryDelayMs 200
```

### Multiple Log Files
```powershell
$ErrorLog = "C:\Logs\errors.log"
$InfoLog = "C:\Logs\info.log"
$DebugLog = "C:\Logs\debug.log"

Write-LogInfo -LogPath $InfoLog -Message "Starting process"
Write-LogDebug -LogPath $DebugLog -Message "Debug: Processing item $i"
Write-LogError -LogPath $ErrorLog -Message "Process failed" -Exception $error
```

## Log Format

Log entries are formatted as:
```
[yyyy-MM-dd HH:mm:ss.fff] [Level] Message
  Exception: ExceptionType: Exception message (if provided)
```

**Example output:**
```
[2024-03-15 14:30:25.123] [Information] Application started successfully
[2024-03-15 14:30:26.456] [Warning] Configuration file missing, using defaults
[2024-03-15 14:30:27.789] [Error] Database connection failed
  Exception: SqlException: A network-related or instance-specific error occurred
```

## Thread Safety

The module uses named mutexes to ensure thread-safe file writing across multiple PowerShell processes and runspaces. Each log file gets its own mutex based on the file path.

## Console Output

In addition to file logging, messages are also written to the console using appropriate PowerShell cmdlets:
- **Debug**: `Write-Debug`
- **Information**: `Write-Verbose`
- **Warning**: `Write-Warning`
- **Error/Critical**: `Write-Error`

## Error Handling

- Automatic directory creation for log files
- Retry logic with configurable attempts and delays
- Graceful fallback with error messages if logging fails
- Proper mutex cleanup in all scenarios

## Requirements

- PowerShell 5.1 or later
- Write permissions to the log directory
- .NET Framework support for System.Threading.Mutex

## Best Practices

1. **Use appropriate log levels** - Reserve Critical for severe errors, use Debug for detailed troubleshooting
2. **Include context in messages** - Add relevant variable values and operation details
3. **Log exceptions** - Always include the Exception parameter when available
4. **Use consistent log paths** - Consider using a single log file per application or feature
5. **Monitor log file sizes** - Implement log rotation for long-running applications

## Contributing

Contributions are welcome! Please ensure all functions include proper help documentation and follow PowerShell best practices.

## License

This project is licensed under the MIT License - see the LICENSE file for details.