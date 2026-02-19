function Test-GitInstalled {
    winget list --id Git.Git -e > $null 2>&1
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-GitInstalled)) {
    Write-Host "Git is not installed."
    Write-Host "Installing Git"
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    
    Write-Host "Git installed, Restart Powershell script"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git ist installed, but in the wrong PATH."
    exit 1
}
Write-Host "Git installed correctly"

Set-Location ..
$currentPath = (Get-Location).Path
Write-Host "Execution in: $currentPath"
git config --local core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set core.hooksPath."
    exit 1
}
Write-Host "Githooks installed succesfully"
Start-Sleep -Seconds 3