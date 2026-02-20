Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Check if $LASTEXITCODE is part of the allowed $OkCodes Array, if not throw error message
function Assert-LastExitCode([string]$Step, [int[]]$OkCodes = @(0)) {
    if ($OkCodes -notcontains $LASTEXITCODE) {
        Write-Host "$Step failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Install Git, if not allready installed
Write-Host "Checking for Git ..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Starting installation ..."

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Cannot install Git automatically" -ForegroundColor Red
        exit 127
    }

	# Install Git
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent
    Assert-LastExitCode "winget install Git"
	
	# Reload PATH
	Write-Host "Reload PATH ..."
	$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
	$userPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")
	$env:Path    = "$machinePath;$userPath"

	# Re-check Git
	$gitCmd = Get-Command git -ErrorAction SilentlyContinue
	if (-not $gitCmd) {
		Write-Host "Git still not found (PATH issue)" -ForegroundColor Red
		exit 127
	}
}

# Smoke test
& git --version | Write-Host
Assert-LastExitCode "git --version"

# Use script location as anchor, go to repo root (if possible)
Set-Location $PSScriptRoot

# Ensure we're in a repo
& git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not inside a Git repository. Cannot set local hooksPath." -ForegroundColor Red
    exit 100
}

# Go to repo root
$repoRoot = (& git rev-parse --show-toplevel).Trim()
Assert-LastExitCode "git rev-parse --show-toplevel"
Set-Location $repoRoot
Write-Host "Execution in: $repoRoot"

# Ensure hooks folder exists
if (-not (Test-Path ".githooks")) {
    Write-Host ".githooks folder not found in repo root." -ForegroundColor Red
    exit 101
}

# Install githooks
& git config --local core.hooksPath .githooks
Assert-LastExitCode "git config core.hooksPath"

Write-Host "Githooks installed successfully" -ForegroundColor Green
exit