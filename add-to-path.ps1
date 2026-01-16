# Script to add %USERPROFILE%\bin to PATH permanently
# Run this script as Administrator or it will add to user PATH

$binDir = "$env:USERPROFILE\bin"

# Check if already in PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -split ';' -contains $binDir) {
    Write-Host "[INFO] $binDir is already in your PATH." -ForegroundColor Green
    exit 0
}

# Add to user PATH
Write-Host "[INFO] Adding $binDir to user PATH..." -ForegroundColor Yellow
$newPath = if ($currentPath) { "$currentPath;$binDir" } else { $binDir }
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# Update current session PATH
$env:Path += ";$binDir"

Write-Host "[OK] PATH updated successfully!" -ForegroundColor Green
Write-Host "[INFO] Please restart your terminal for changes to take effect in new sessions." -ForegroundColor Yellow
Write-Host "[INFO] You can test it now: agent-manager --version" -ForegroundColor Cyan
