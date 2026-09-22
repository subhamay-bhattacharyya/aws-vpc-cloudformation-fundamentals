#!/bin/bash
# Auto-update package.json fields from repository metadata
# Run when creating a new CloudFormation repository

set -e

PKG_FILE="${1:-.}/package.json"
REPO_DIR="${2:-.}"

# Extract GitHub org from git remote, fallback to parameter or default
if [ -z "$3" ]; then
  GITHUB_ORG=$(git -C "$REPO_DIR" config --get remote.origin.url 2>/dev/null | sed -E 's#(https://github\.com/|git@github\.com:)([^/]+)/.*#\2#' || echo "subhamay-bhattacharyya-cfn")
else
  GITHUB_ORG="$3"
fi

if [ ! -f "$PKG_FILE" ]; then
  echo "Error: $PKG_FILE not found"
  exit 1
fi

# Extract repo name from directory (convert underscores to hyphens)
REPO_NAME=$(basename "$REPO_DIR" | tr '_' '-')

# Convert to GitHub-friendly format (lowercase, kebab-case)
GITHUB_REPO=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')

# Update package.json using node/jq (portable JSON update)
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('$PKG_FILE', 'utf8'));

// Update name
pkg.name = '$GITHUB_REPO';

// Update repository URL
if (!pkg.repository) pkg.repository = {};
pkg.repository.type = 'git';
pkg.repository.url = 'git+https://github.com/$GITHUB_ORG/$GITHUB_REPO.git';

// Update bugs URL
if (!pkg.bugs) pkg.bugs = {};
pkg.bugs.url = 'https://github.com/$GITHUB_ORG/$GITHUB_REPO/issues';

// Update homepage
pkg.homepage = 'https://github.com/$GITHUB_ORG/$GITHUB_REPO#readme';

fs.writeFileSync('$PKG_FILE', JSON.stringify(pkg, null, 2) + '\n');
console.log('✅ Updated package.json for: $GITHUB_REPO');
"
