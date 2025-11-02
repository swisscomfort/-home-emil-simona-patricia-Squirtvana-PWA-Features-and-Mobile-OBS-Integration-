# GitHub Repository Setup Guide

This guide helps you set up a GitHub repository for Squirtvana PWA.

## Step 1: Create GitHub Repository

### On GitHub.com

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** `squirtvana` (or `squirtvana-pwa`)
   - **Description:** Mobile streaming control center PWA
   - **Visibility:** Public (for open source) or Private (for internal)
   - **Initialize:** NO (we already have commits)
3. Click **Create repository**

### Example URL
```
https://github.com/yourusername/squirtvana.git
```

---

## Step 2: Add Remote and Push

Replace `yourusername` with your GitHub username:

```bash
cd "/workspaces/-home-emil-simona-patricia-Squirtvana-PWA-Features-and-Mobile-OBS-Integration-/Squirtvana PWA Features and Mobile OBS Integration (2)"

# Remove old origin (if conflicts)
git remote remove origin 2>/dev/null || true

# Add new GitHub remote
git remote add origin https://github.com/yourusername/squirtvana.git

# Rename branch if needed (local to main)
git branch -M main

# Push to GitHub
git push -u origin main
```

---

## Step 3: Setup GitHub Pages (Optional)

For PWA hosting on GitHub Pages:

1. Go to **Repository Settings** → **Pages**
2. **Source:** Deploy from a branch
3. **Branch:** main
4. **Folder:** `/root` or custom folder
5. Click **Save**

Your PWA will be at: `https://yourusername.github.io/squirtvana`

---

## Step 4: Configure Repository Settings

### General Settings

1. **Default branch:** main ✓
2. **Require pull request reviews:** ON (recommended)
3. **Dismiss stale pull request approvals:** ON
4. **Require status checks to pass:** ON (once CI/CD setup)

### Protect Main Branch

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. **Branch name pattern:** `main`
4. Enable:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date

### Manage Secrets

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add:
   - **OPENROUTER_KEY** (for CI/CD if needed)
   - **ELEVENLABS_KEY** (for CI/CD if needed)
4. Never add these to code!

---

## Step 5: Add GitHub Features

### Enable Discussions (Optional)

1. **Settings** → **General**
2. ✅ **Discussions** - Enable for community discussions
3. Choose discussion categories

### Enable GitHub Pages

```bash
# In your repo root
mkdir -p .github/workflows
```

### Add Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug Report
about: Report a bug
title: "[BUG] "
---

## Description
Clear description of the bug.

## Steps to Reproduce
1. Step 1
2. Step 2

## Expected vs Actual
- Expected: ...
- Actual: ...

## Environment
- OS: [iOS/Android]
- Browser: [Safari/Chrome]
- Version: [1.0.0]
```

### Add PR Template

Create `.github/pull_request_template.md`:

```markdown
## Description
Brief description of changes.

## Type
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Breaking change

## Related Issues
Fixes #123

## Testing
How was this tested?

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No hardcoded secrets
```

---

## Step 6: GitHub Actions (CI/CD)

### Auto-linting on PR

Create `.github/workflows/lint.yml`:

```yaml
name: Lint

on: [pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install
        run: npm install
      
      - name: Lint
        run: npm run lint
```

### Build on Release

Create `.github/workflows/build.yml`:

```yaml
name: Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install
        run: npm install
      
      - name: Build
        run: npm run build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/
```

---

## Step 7: Create Releases

### Manual Release

```bash
# Tag current commit
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0
```

### On GitHub

1. Go to **Releases** → **Draft a new release**
2. **Choose a tag:** v1.0.0
3. **Title:** Squirtvana v1.0.0
4. **Description:**
   ```markdown
   ## Release Notes

   ### Features
   - Initial PWA release
   - OBS integration
   - AI content generation
   - Text-to-speech support

   ### Installation
   See README.md for setup instructions

   ### Contributors
   Thank you to all contributors!
   ```
5. Attach binaries (optional - dist/ folder)
6. Click **Publish release**

---

## Step 8: Add Badges to README

Add these to your README.md:

```markdown
[![GitHub release](https://img.shields.io/github/v/release/yourusername/squirtvana?style=flat-square)](https://github.com/yourusername/squirtvana/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/yourusername/squirtvana/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/yourusername/squirtvana?style=flat-square)](https://github.com/yourusername/squirtvana/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/yourusername/squirtvana?style=flat-square)](https://github.com/yourusername/squirtvana/issues)
```

---

## Step 9: Verification Checklist

Before launching:

- [ ] Repository URL: https://github.com/yourusername/squirtvana
- [ ] Main branch protected
- [ ] README visible and comprehensive
- [ ] LICENSE file present
- [ ] .gitignore configured
- [ ] No secrets in code/history
- [ ] First release/tag created
- [ ] GitHub Pages configured (optional)
- [ ] Contributing guidelines available
- [ ] Issues/discussions enabled

---

## Common Commands

```bash
# Clone repository
git clone https://github.com/yourusername/squirtvana.git

# Create new branch
git checkout -b feature/my-feature

# Commit changes
git commit -m "feat: add my feature"

# Push to GitHub
git push origin feature/my-feature

# Pull latest changes
git pull origin main

# Fetch all updates
git fetch --all

# View commits
git log --oneline
```

---

## Troubleshooting

### Error: "fatal: Could not read from repository"
```bash
# Check remote
git remote -v

# Reset remote
git remote set-url origin https://github.com/yourusername/squirtvana.git
```

### Error: "Permission denied (publickey)"
```bash
# Setup SSH key
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub  # Copy and add to GitHub
```

### Large file warning
```bash
# Remove large file from history
git rm --cached large-file.zip
git commit --amend
git push --force-with-lease
```

---

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Push local commits
3. ✅ Setup branch protection
4. ✅ Configure GitHub Pages
5. ✅ Create first release
6. ✅ Share repository link

**Your GitHub Repository URL:**
```
https://github.com/yourusername/squirtvana
```

Update this in README.md and documentation.

---

For more GitHub help: [GitHub Docs](https://docs.github.com/)
