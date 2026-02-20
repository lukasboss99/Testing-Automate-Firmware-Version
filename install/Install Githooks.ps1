if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git installation not found."
    exit 1
}
Write-Host "Git installaton found"

Set-Location ..
$currentPath = (Get-Location).Path
Write-Host "Execution in: $currentPath"
git config --local core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install githooks"
	Write-Host "Exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "Githooks installed succesfully"
exit 0