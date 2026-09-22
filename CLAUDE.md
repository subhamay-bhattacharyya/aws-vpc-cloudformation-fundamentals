# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **CloudFormation template repository** that provides reusable nested stack templates for deploying VPC infrastructure with a public subnet. Templates follow the nested stack pattern and are designed to be referenced by parent CloudFormation stacks.

**Key characteristics:**

- Nested CloudFormation templates (referenced via `TemplateURL`)
- VPC creation with configurable CIDR blocks
- Public subnet with internet gateway and route table configuration
- Parameterized configuration for multi-environment deployments (dev, staging, prod)
- Automated semantic versioning and releases
- AWS OIDC authentication for CI/CD deployments

## Project Structure

```text
cloudformation/
├── vpc-fundamentals.yaml          # VPC CloudFormation template
└── parameters.json                # Template parameters

scripts/
├── update-package-json.sh         # Auto-updates package.json metadata
├── update-readme.sh               # Auto-generates README
└── plugins/
    ├── release.config.js          # Semantic-release configuration
    ├── analyze-commits.js         # Custom commit analyzer
    ├── generate-notes.js          # Custom release notes generator
    ├── prepare.js                 # Release preparation plugin
    ├── publish.js                 # Release publishing plugin
    └── verify-conditions.js       # Release verification plugin

.github/workflows/
├── ci.yaml                        # Validates, deploys, and cleans up templates
├── release.yaml                   # Semantic release on push to main
├── create-branch.yaml             # Auto-create feature branches from issues
├── claude-code-review.yaml        # CloudFormation code review workflow
├── claude.yaml                    # Claude integration workflow
├── notify.yaml                    # Notification workflow
└── setup-environments.yaml        # Environment setup workflow

.claude/
└── settings.json                  # Claude Code workspace settings

.env/
└── environments.yaml              # Environment configuration

.devcontainer/
└── devcontainer.json              # Dev container setup (Node.js 20)

CONTRIBUTING.md                    # Contribution guidelines
CHANGELOG.md                        # Release changelog
CODE_OF_CONDUCT.md                 # Community code of conduct
LICENSE                            # Project license
package.json                       # Dependencies: semantic-release, commitizen
README.md                          # Template documentation
```

## Project Skills & Documentation

This project includes project-specific skills and guides documented in `.claude/.skills/`:

**Available Project Skills:**

1. **contributing** (`.claude/.skills/contributing/SKILL.md`)
   - Guidelines and workflow for contributing to CloudFormation templates
   - Branch naming conventions: `{type}/CFN-{issue-number}-{description}`
   - Development setup, testing requirements, and code quality standards
   - Conventional commits workflow with semantic versioning

2. **package-json** (`.claude/.skills/package-json/SKILL.md`)
   - Package.json configuration and requirements
   - npm scripts, dependencies, and semantic versioning setup
   - Project metadata and required fields

3. **github-ci-workflow** (`.claude/.skills/github-ci-workflow/SKILL.md`)
   - CloudFormation Template Lifecycle CI/CD workflow guide
   - GitHub Actions workflow setup and AWS OIDC authentication
   - Template validation, deployment, and cleanup procedures
   - Troubleshooting CI/CD issues

4. **vpc-fundamentals** (`.claude/.skills/vpc-fundamentals/SKILL.md`)
   - Guide for creating nested stack templates for VPC and subnet deployment
   - VPC template structure, parameters, and outputs
   - Best practices for CIDR planning, tagging, and security
   - Multi-environment configurations and common patterns
   - Template validation and CI/CD integration

**How to Use Project Skills:**

When working on VPC templates, contribution workflows, package setup, or CI/CD topics, reference the relevant skill from `.claude/.skills/` or ask Claude to review the specific skill documentation.

See `.claude/settings.json` for the complete project skill registry.

## Getting Started After Cloning

### Initial Setup

After cloning this repository, the following automation runs automatically:

1. **package.json metadata update** — When you create or modify `package.json` in Claude Code, the `scripts/update-package-json.sh` script automatically:

   - Extracts the GitHub organization from your git remote URL
   - Updates the repository URL, bugs URL, and homepage fields
   - Ensures package.json reflects your actual GitHub repo location

   **No manual action needed** — this happens automatically via a Claude Code hook.

2. **README.md generation** — When you create a new `README.md` in Claude Code, the `scripts/update-readme.sh` script automatically:

   - Generates a professional README with status badges
   - Extracts your GitHub organization and repository name from git remote
   - Creates placeholder sections for Overview, Features, Quick Start, etc.
   - Skips generation if README.md already has content

   **No manual action needed** — this happens automatically via a Claude Code hook.

3. **CONTRIBUTING.md guidelines** — Review [CONTRIBUTING.md](./CONTRIBUTING.md) for:

   - Branch naming conventions
   - Development workflow
   - Commit message requirements
   - Pull request process

### Manual package.json Update (if needed)

If you need to manually run the update (e.g., after changing remotes):

```bash
./scripts/update-package-json.sh
```

The script automatically detects your GitHub organization from the git remote. To override it:

```bash
./scripts/update-package-json.sh . . my-custom-org
```

### Manual README.md Generation (if needed)

To manually generate or regenerate README.md:

```bash
./scripts/update-readme.sh
```

The script automatically extracts badges and metadata from your git remote. It only generates README.md if it doesn't already exist or is empty, preventing accidental overwrites.

## Development Commands

### Install dependencies

```bash
npm ci
```

### Trigger semantic release (usually automatic on main)

```bash
npm run release
```

### Commit with conventional commit format

```bash
npx cz commit
```

Select `feat`, `fix`, or `chore` type. Only `feat` and `fix` trigger releases.

## Architecture

This repo uses **nested stack templates** — templates referenced from parent stacks via `TemplateURL`. Nested templates are self-contained and export outputs for cross-stack references via `Outputs` with `Export`.

The CI workflow (`.github/workflows/ci.yaml`) validates and deploys templates on PR; release workflow (`.github/workflows/release.yaml`) runs on merge to main using semantic versioning.

## Modifying Templates

1. Edit `cloudformation/vpc-fundamentals.yaml` or update `cloudformation/parameters.json`
2. Create a PR with a conventional commit (e.g., `feat: add public subnet configuration`)
3. CI validates and deploys automatically
4. Merge to main → release workflow creates version tag and GitHub release

## Dev Container

Pre-configured with:

- Node.js 20
- GitHub Copilot extension

Use via VS Code: `code --remote-container-url <repo-url>`

## Current Branch

Main branch is the release branch. Feature work branches from here and merges back via PR. Branch naming follows: `{type}/CFN-{issue-number}-{slug}` (e.g., `feature/CFN-42-add-encryption`).
