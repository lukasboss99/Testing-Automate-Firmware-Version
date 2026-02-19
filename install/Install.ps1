function Test-GitInstalled {
    winget list --id Git.Git -e > $null 2>&1
    return ($LASTEXITCODE -eq 0)
}



if (-not (Test-GitInstalled)) {
    Write-Host "Git ist nicht installiert."
    Write-Host "Installiere Git"
    winget install --id Git.Git -e --source winget
    
    Write-Host "Git installiert, starte Powershell neu"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git ist installiert, aber noch nicht im PATH."
    exit
}

Write-Host "Git ist korrekt installiert"
Get-Location
cd ..
$currentPath = Get-Location
Write-Host $currentPath
git config --local core.hooksPath .githooks
Start-Sleep -Seconds 5