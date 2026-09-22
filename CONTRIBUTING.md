# Contributing

Thank you for considering contributing to the AWS VPC CloudFormation Fundamentals project! We’re excited to have you on board.

## Development Setup

### Prerequisites

- Node.js 20 or higher
- npm 10 or higher
- Git

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals.git
cd aws-vpc-cloudformation-fundamentals

# Add upstream remote (if forked)
git remote add upstream https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals.git

# Install dependencies
npm ci
```

## Branch Naming Convention

Use the pattern: `{type}/CFN-{issue-number}-{description}`

Types:
- `feature/` — New functionality
- `bug/` — Bug fixes
- `docs/` — Documentation updates
- `chore/` — Maintenance tasks
- `refactor/` — Code refactoring

Examples:
- `feature/CFN-58-add-encryption`
- `bug/CFN-42-fix-policy`
- `docs/CFN-100-update-readme`

## Development Workflow

### 1. Create or Assign an Issue

Create a GitHub issue with a clear title and description. When assigned, a feature branch is auto-created.

### 2. Make Code Changes

```bash
# Update your branch
git fetch upstream
git rebase upstream/main

# Write code and run tests
npm test
npm run lint
```

### 3. Commit Changes

Use conventional commits for automatic versioning:

```bash
npx cz commit
```

Commit types:
- `feat:` → MINOR version bump (e.g., 0.1.0 → 0.2.0)
- `fix:` → PATCH version bump (e.g., 0.1.0 → 0.1.1)
- `docs:` → No version bump
- `chore:` → No version bump
- `BREAKING CHANGE:` → MAJOR version bump (e.g., 0.1.0 → 1.0.0)

Example commit message:
```
feat: add support for S3 bucket encryption policies
```

### 4. Push & Create Pull Request

```bash
git push origin feature/CFN-123-description
```

Create a pull request with:
- Clear description of changes
- Reference to the related issue number
- Type of change (feature/fix/docs/etc)

### 5. Review & Merge

- All GitHub checks must pass
- Maintainers will review and provide feedback
- Merge to `main` triggers automatic semantic versioning and release

## Testing

All changes must include appropriate tests:

```bash
npm test
```

## Code Quality

Before submitting a pull request, run code review and simplification checks:

```bash
/code-review high --fix
/simplify
```

## Documentation

- Update `README.md` if adding new features or changing functionality
- Update inline code comments for complex logic
- Keep documentation synchronized with actual code behavior

## Reporting Bugs

When reporting bugs, please include:
- Clear description of the issue
- Steps to reproduce the problem
- Expected vs actual behavior
- Screenshots or error logs (if applicable)
- Environment details (OS, Node.js version, etc.)

Check [open issues](https://github.com/subhamay-bhattacharyya/aws-vpc-cloudformation-fundamentals/issues) before creating a new one.

## Recognition

Contributors are recognized in:
- `CHANGELOG.md` (for significant changes)
- Project acknowledgments (for major contributors)

## Questions?

- Open a GitHub Discussion
- Check existing documentation in `README.md` and `CLAUDE.md`
- Contact maintainers via GitHub issues

---

Thanks for contributing! You’re awesome. 🎉
