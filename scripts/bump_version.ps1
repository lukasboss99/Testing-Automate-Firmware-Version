# =============================================================================
# bump_version.ps1 — Manual version bump script (PowerShell)
# =============================================================================
# Usage:
#   .\scripts\bump_version.ps1 major    # 0.1.7 -> 1.0.0
#   .\scripts\bump_version.ps1 minor    # 0.1.7 -> 0.2.0
#   .\scripts\bump_version.ps1 patch    # 0.1.7 -> 0.1.8
#   .\scripts\bump_version.ps1          # (no argument = shows current version)
# =============================================================================

param(
    [Parameter(Position = 0)]
    [ValidateSet("major", "minor", "patch", "")]
    [string]$BumpType = ""
)

$RepoRoot = (git rev-parse --show-toplevel).Trim()
$VersionFile = Join-Path $RepoRoot "VERSION"

if (-not (Test-Path $VersionFile)) {
    Write-Error "VERSION file not found at $VersionFile"
    exit 1
}

$Version = (Get-Content $VersionFile -Raw).Trim()
$Parts = $Version -split "\."

if ($Parts.Count -ne 3) {
    Write-Error "Invalid version format: '$Version'. Expected MAJOR.MINOR.PATCH"
    exit 1
}

[int]$Major = $Parts[0]
[int]$Minor = $Parts[1]
[int]$Patch = $Parts[2]

switch ($BumpType) {
    "major" {
        $Major++
        $Minor = 0
        $Patch = 0
    }
    "minor" {
        $Minor++
        $Patch = 0
    }
    "patch" {
        $Patch++
    }
    default {
        Write-Host "Current version: $Version"
        Write-Host ""
        Write-Host "Usage: .\scripts\bump_version.ps1 [major|minor|patch]"
        Write-Host "  major  - Increment major version (resets minor and patch to 0)"
        Write-Host "  minor  - Increment minor version (resets patch to 0)"
        Write-Host "  patch  - Increment patch version"
        exit 0
    }
}

$NewVersion = "$Major.$Minor.$Patch"
Set-Content -Path $VersionFile -Value $NewVersion -NoNewline
# Add a trailing newline
Add-Content -Path $VersionFile -Value ""

Write-Host "Version bumped: $Version -> $NewVersion"
Write-Host ""
Write-Host "The pre-commit hook will NOT additionally increment this commit."
Write-Host "To commit this change:"
Write-Host "  git add VERSION"
Write-Host "  git commit --no-verify -m `"Bump version to $NewVersion`""
