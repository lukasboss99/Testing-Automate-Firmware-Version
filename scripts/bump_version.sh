#!/bin/bash
# =============================================================================
# bump_version.sh — Manual version bump script
# =============================================================================
# Usage:
#   ./scripts/bump_version.sh major    # 0.1.7 -> 1.0.0
#   ./scripts/bump_version.sh minor    # 0.1.7 -> 0.2.0
#   ./scripts/bump_version.sh patch    # 0.1.7 -> 0.1.8
#   ./scripts/bump_version.sh          # (no argument = shows current version)
# =============================================================================

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
VERSION_FILE="$REPO_ROOT/VERSION"

if [ ! -f "$VERSION_FILE" ]; then
    echo "ERROR: VERSION file not found at $VERSION_FILE"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
PATCH=$(echo "$VERSION" | cut -d. -f3)

BUMP_TYPE="${1:-}"

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    "")
        echo "Current version: $VERSION"
        echo ""
        echo "Usage: $0 [major|minor|patch]"
        echo "  major  — Increment major version (resets minor and patch to 0)"
        echo "  minor  — Increment minor version (resets patch to 0)"
        echo "  patch  — Increment patch version"
        exit 0
        ;;
    *)
        echo "ERROR: Invalid bump type '$BUMP_TYPE'"
        echo "Usage: $0 [major|minor|patch]"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Version bumped: $VERSION -> $NEW_VERSION"
echo ""
echo "The pre-commit hook will NOT additionally increment this commit."
echo "To commit this change:"
echo "  git add VERSION"
echo "  git commit --no-verify -m \"Bump version to $NEW_VERSION\""
