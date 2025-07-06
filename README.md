# AaTurpin.PSLogger

A PowerShell module providing thread-safe logging capabilities with multiple log levels and exception handling support.

## Features

- **Thread-safe logging** with mutex synchronization
- **Multiple log levels**: Debug, Information, Warning, Error, Critical
- **Exception handling** support with detailed error logging
- **Retry logic** for robust file operations
- **Automatic directory creation** for log file paths
- **Console output** based on log level
- **UTF-8 encoding** for proper character support

## Installation

First, register the NuGet repository if you haven't already:

```powershell
Register-PSRepository -Name "NuGet" -SourceLocation "https://api.nuget.org/v3/index.json" -PublishLocation "https://www.nuget.org/api/v2/package/" -InstallationPolicy Trusted
```

Then install the module:

```powershell
Install-Module -Name AaTurpin.PSLogger -Repository NuGet -Scope CurrentUser
```

Or for all users (requires administrator privileges):

```powershell
Install-Module -Name AaTurpin.PSLogger -Repository NuGet -Scope AllUsers
```

## Quick Start

```powershell
# Import the module
Import-Module AaTurpin.PSLogger

# Basic logging
Write-LogInfo -LogPath "C:\Logs\app.log" -Message "Application started"
Write-LogWarning -LogPath "C:\Logs\app.log" -Message "Low disk space detected"
Write-LogError -LogPath "C:\Logs\app.log" -Message "Database connection failed"

# Logging with exception details
try {
    Get-Item "nonexistent-file.txt"
} catch {
    Write-LogError -LogPath "C:\Logs\app.log" -Message "File operation failed" -Exception $_.Exception
}
```

## Available Functions

| Function | Description | Log Level |
|----------|-------------|-----------|
| `Write-LogDebug` | Debug-level logging for detailed troubleshooting | Debug |
| `Write-LogInfo` | Informational messages for general application flow | Information |
| `Write-LogWarning` | Warning messages for potential issues | Warning |
| `Write-LogError` | Error messages for handled exceptions | Error |
| `Write-LogCritical` | Critical messages for severe issues | Critical |

## Parameters

All logging functions support the following parameters:

### Required Parameters
- **LogPath** (string): The path to the log file where entries will be written
- **Message** (string): The log message to write

### Optional Parameters
- **Exception** (System.Exception): Exception object to include detailed error information
- **MaxRetries** (int): Maximum retry attempts for file writing (default: 3)
- **RetryDelayMs** (int): Delay between retries in milliseconds (default: 100)

## Examples

### Basic Logging

```powershell
# Information logging
Write-LogInfo -LogPath "C:\Logs\myapp.log" -Message "User logged in successfully"

# Warning logging
Write-LogWarning -LogPath "C:\Logs\myapp.log" -Message "Disk space below 10%"

# Error logging
Write-LogError -LogPath "C:\Logs\myapp.log" -Message "Failed to connect to database"
```

### Exception Logging

```powershell
try {
    # Some operation that might fail
    $result = Invoke-RestMethod -Uri "https://api.example.com/data"
    Write-LogInfo -LogPath "C:\Logs\api.log" -Message "API call successful"
} catch {
    Write-LogError -LogPath "C:\Logs\api.log" -Message "API call failed" -Exception $_.Exception
}
```

### Custom Retry Settings

```powershell
# Increase retries for critical operations
Write-LogCritical -LogPath "C:\Logs\critical.log" -Message "System shutdown initiated" -MaxRetries 5 -RetryDelayMs 250
```

### Debug Logging

```powershell
# Debug information (useful for troubleshooting)
$itemCount = 150
Write-LogDebug -LogPath "C:\Logs\debug.log" -Message "Processing $itemCount items"
```

## Log Format

Log entries are formatted as:

```
[2025-07-03 14:30:25.123] [Information] Application started successfully
[2025-07-03 14:30:26.456] [Error] Database connection failed
  Exception: SqlException: A network-related or instance-specific error occurred
```

- **Timestamp**: yyyy-MM-dd HH:mm:ss.fff format
- **Level**: Debug, Information, Warning, Error, or Critical
- **Message**: Your custom message
- **Exception**: (when provided) Exception type and message

## Thread Safety

The module uses named mutexes to ensure thread-safe file operations, making it safe to use in:

- Multi-threaded PowerShell scripts
- PowerShell jobs running in parallel
- Multiple PowerShell sessions writing to the same log file

## Console Output

In addition to file logging, messages are also displayed in the console based on their level:

- **Debug**: Uses `Write-Debug` (requires `-Debug` switch or `$DebugPreference`)
- **Information**: Uses `Write-Verbose` (requires `-Verbose` switch or `$VerbosePreference`)
- **Warning**: Uses `Write-Warning` (always displayed in yellow)
- **Error/Critical**: Uses `Write-Error` (always displayed in red)

## Error Handling

The module includes robust error handling:

- **Automatic directory creation** if the log directory doesn't exist
- **Retry logic** with exponential backoff for file access issues
- **Mutex timeout protection** (5-second timeout)
- **Graceful fallback** with error messages if logging fails

## Best Practices

### Use Appropriate Log Levels

```powershell
# Use Debug for detailed troubleshooting information
Write-LogDebug -LogPath $logFile -Message "Variable value: $myVariable"

# Use Info for general application flow
Write-LogInfo -LogPath $logFile -Message "Processing batch started"

# Use Warning for potential issues that don't stop execution
Write-LogWarning -LogPath $logFile -Message "Retrying failed operation"

# Use Error for handled exceptions
Write-LogError -LogPath $logFile -Message "Operation failed" -Exception $_.Exception

# Use Critical for severe issues requiring immediate attention
Write-LogCritical -LogPath $logFile -Message "System resources exhausted"
```

### Centralized Log Path Management

```powershell
# Define log path once
$logPath = "C:\Logs\MyApplication\app.log"

# Use throughout your script
Write-LogInfo -LogPath $logPath -Message "Application started"
# ... rest of your script
Write-LogInfo -LogPath $logPath -Message "Application completed"
```

### Exception Logging Pattern

```powershell
function Invoke-SafeOperation {
    param($InputData)
    
    try {
        # Your operation here
        $result = Process-Data -Data $InputData
        Write-LogInfo -LogPath $logPath -Message "Data processed successfully"
        return $result
    } catch {
        Write-LogError -LogPath $logPath -Message "Failed to process data" -Exception $_.Exception
        throw
    }
}
```

## Troubleshooting

### Repository Registration Issues

If you encounter issues with the NuGet repository registration, try:

```powershell
# Check existing repositories
Get-PSRepository

# Remove existing NuGet repository if it exists
Unregister-PSRepository -Name "NuGet" -ErrorAction SilentlyContinue

# Re-register with correct settings
Register-PSRepository -Name "NuGet" -SourceLocation "https://api.nuget.org/v3/index.json" -PublishLocation "https://www.nuget.org/api/v2/package/" -InstallationPolicy Trusted
```

### Installation Issues

If installation fails, ensure you have:

- PowerShell execution policy allows module installation
- Internet connectivity to reach api.nuget.org
- Appropriate permissions for the installation scope

## Requirements

- **PowerShell 5.1** or later
- **Windows** (uses Windows-specific mutex implementation)
- **Write permissions** to the specified log directory
- **Internet access** for initial module installation

## License

This module is licensed under the MIT License. See the [license](https://github.com/aturpin0504/AaTurpin.PSLogger?tab=MIT-1-ov-file) for details.

## Contributing

Contributions are welcome! Please visit the [project repository](https://github.com/aturpin0504/AaTurpin.PSLogger) for more information.

## Release Notes

### Version 1.0.2
- Initial release with thread-safe logging capabilities
- Support for multiple log levels (Debug, Information, Warning, Error, Critical)
- Mutex synchronization and retry logic
- Exception handling support
- Automatic directory creation
- UTF-8 encoding support