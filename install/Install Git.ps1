if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git installation found."
    exit 0
}
Write-Host "Git installation not found"
Write-Host "Starting Git installation ..."

winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent

if ($LASTEXITCODE -ne 0) {
    Write-Host "Installation failed with exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}
exit 0