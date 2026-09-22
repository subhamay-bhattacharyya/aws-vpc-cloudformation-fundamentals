#!/bin/bash
# Auto-generate README.md with badges from repository metadata
# Run when creating a new repository

set -e

README_FILE="${1:-.}/README.md"
REPO_DIR="${2:-.}"

# Extract repository info from git
GITHUB_REPO_URL=$(git -C "$REPO_DIR" config --get remote.origin.url 2>/dev/null || echo "")
GITHUB_ORG=$(echo "$GITHUB_REPO_URL" | sed -E 's#(https://github\.com/|git@github\.com:)([^/]+)/.*#\2#')
REPO_NAME=$(echo "$GITHUB_REPO_URL" | sed -E 's#.*[:/]([^/]+)(\.git)?$#\1#')

# Fallback to directory name if git extraction fails
if [ -z "$REPO_NAME" ]; then
  REPO_NAME=$(basename "$REPO_DIR" | tr '_' '-')
fi

# Skip if README already exists and has content
if [ -f "$README_FILE" ] && [ -s "$README_FILE" ]; then
  exit 0
fi

# Create README.md with badges and sections
cat > "$README_FILE" << 'EOFREADME'
# Project Name

<!-- Row 1: Status - Most Important -->
[![Release](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER/actions/workflows/release.yaml/badge.svg)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER)&nbsp;[![GitHub Repo](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER)&nbsp;[![Issues](https://img.shields.io/github/issues/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER/issues)&nbsp;[![Last Commit](https://img.shields.io/github/last-commit/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER/commits)

<!-- Row 2: Code Quality -->
[![Top Language](https://img.shields.io/github/languages/top/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER)&nbsp;[![Commits](https://img.shields.io/github/commit-activity/t/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER/commits)

<!-- Row 3: Tech Stack -->
[![Built with Claude Code](https://img.shields.io/badge/Built_with-Claude_Code-D97757?logo=anthropic&logoColor=white)](https://claude.ai/)

<!-- Row 4: Repository Info -->
[![Files](https://img.shields.io/github/directory-file-count/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER)&nbsp;[![Repo Size](https://img.shields.io/github/repo-size/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER)&nbsp;[![Release Date](https://img.shields.io/github/release-date/ORG_PLACEHOLDER/REPO_PLACEHOLDER)](https://github.com/ORG_PLACEHOLDER/REPO_PLACEHOLDER/releases)

<!-- Row 5: Custom Metrics -->
[![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/ORG_PLACEHOLDER/GIST_ID_PLACEHOLDER/raw/REPO_PLACEHOLDER.json)](https://gist.github.com/ORG_PLACEHOLDER/GIST_ID_PLACEHOLDER)

## Overview

TODO: Add a brief description of what this project does and its main purpose.

## Features

- TODO: Add feature 1
- TODO: Add feature 2
- TODO: Add feature 3

## Quick Start

### Prerequisites

- TODO: Add prerequisite 1
- TODO: Add prerequisite 2

### Installation

```bash
# TODO: Add installation steps
npm install
```

### Usage

```bash
# TODO: Add usage examples
npm start
```

## Project Structure

```text
.
├── README.md              # This file
├── package.json           # Dependencies and metadata
├── CONTRIBUTING.md        # Contribution guidelines
└── scripts/               # Utility scripts
```

## Development

### Setup

```bash
npm ci
```

### Building

```bash
# TODO: Add build commands
npm run build
```

### Testing

```bash
# TODO: Add test commands
npm test
```

### Running

```bash
# TODO: Add run commands
npm start
```

## API Reference

TODO: Add API documentation and examples

## Configuration

TODO: Add configuration options and environment variables

## Troubleshooting

TODO: Add common issues and solutions

## Performance Considerations

TODO: Add performance tips and best practices

## Security

TODO: Add security guidelines and best practices

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on:
- Branch naming conventions
- Commit message format
- Pull request process

## Roadmap

TODO: Add planned features and improvements

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and release notes

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created with ❤️ using [Claude Code](https://claude.ai/)
EOFREADME

# Replace placeholders with actual values
if [ -n "$GITHUB_ORG" ] && [ -n "$REPO_NAME" ]; then
  sed -i '' "s/ORG_PLACEHOLDER/$GITHUB_ORG/g" "$README_FILE"
  sed -i '' "s/REPO_PLACEHOLDER/$REPO_NAME/g" "$README_FILE"
  echo "✅ Generated README.md for: $GITHUB_ORG/$REPO_NAME"
  echo "⚠️  Remember to update GIST_ID_PLACEHOLDER with your actual gist ID"
else
  echo "⚠️  Generated README.md with placeholders (update ORG_PLACEHOLDER, REPO_PLACEHOLDER, and GIST_ID_PLACEHOLDER)"
fi
