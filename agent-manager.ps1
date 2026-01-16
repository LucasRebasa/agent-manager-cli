# Agent Manager CLI Wrapper Script for Windows PowerShell
# This script allows running agent-manager without typing 'java -jar'
# Detects Java version and uses the appropriate JAR (Java 8 or Java 21)

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if Java is available
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCmd) {
    Write-Host "Error: Java is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Java 8 or later and ensure it's in your system PATH." -ForegroundColor Yellow
    exit 1
}

# Get Java version
$javaVersionOutput = java -version 2>&1 | Select-String -Pattern "version"
$javaVersion = $javaVersionOutput.ToString()

# Determine which JAR to use
$jarName = $null
if ($javaVersion -match '"(\d+)\.(\d+)') {
    $majorVersion = [int]$matches[1]
    $minorVersion = [int]$matches[2]
    
    if ($majorVersion -eq 1) {
        # Java 8 or earlier (1.8.x)
        if ($minorVersion -eq 8) {
            $jarName = "agent-manager-java8.jar"
        } else {
            Write-Host "Error: Java version $majorVersion.$minorVersion is not supported." -ForegroundColor Red
            Write-Host "Please install Java 8 or Java 21 or later." -ForegroundColor Yellow
            exit 1
        }
    } elseif ($majorVersion -ge 21) {
        # Java 21 or later
        $jarName = "agent-manager-java21.jar"
    } else {
        # Java 9-20, use Java 8 version
        $jarName = "agent-manager-java8.jar"
    }
} else {
    # Fallback: try Java 8 first, then Java 21
    if (Test-Path (Join-Path $ScriptDir "agent-manager-java8.jar")) {
        $jarName = "agent-manager-java8.jar"
    } elseif (Test-Path (Join-Path $ScriptDir "agent-manager-java21.jar")) {
        $jarName = "agent-manager-java21.jar"
    } else {
        $jarName = "agent-manager.jar"
    }
}

$JarPath = Join-Path $ScriptDir $jarName

# Check if JAR exists
if (-not (Test-Path $JarPath)) {
    Write-Host "Error: $jarName not found at $JarPath" -ForegroundColor Red
    Write-Host "Please run install.bat first or ensure the JAR is in the same directory as this script." -ForegroundColor Yellow
    exit 1
}

# Execute the JAR with all passed arguments
& java -jar $JarPath $Arguments
