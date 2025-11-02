# Contributing to Squirtvana

Thank you for your interest in contributing to Squirtvana! This document provides guidelines for contributing.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Making Changes](#making-changes)
5. [Submitting Changes](#submitting-changes)
6. [Coding Standards](#coding-standards)
7. [Commit Messages](#commit-messages)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment. All contributors must:

- Be respectful of differing opinions and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy toward community members
- Be professional and courteous

### Unacceptable Behavior

- Harassment, discrimination, or hateful comments
- Threatening or intimidating language
- Trolling or insulting remarks
- Publishing others' private information
- Other conduct detrimental to community

### Reporting

Report violations to: legal@squirtvana.example

---

## Getting Started

### Prerequisites

- **Node.js** 18+
- **Python** 3.8+
- **Git**
- Text editor (VS Code recommended)

### Fork & Clone

```bash
# 1. Fork on GitHub
# Visit: https://github.com/yourusername/squirtvana

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/squirtvana.git
cd squirtvana

# 3. Add upstream remote
git remote add upstream https://github.com/yourusername/squirtvana.git

# 4. Create feature branch
git checkout -b feature/your-feature-name
```

---

## Development Setup

### Frontend Setup

```bash
# Install Node dependencies
npm install

# Create environment file
cp .env.example .env

# Add your API keys to .env
nano .env

# Start development server
npm run dev
```

### Backend Setup

```bash
# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Run Flask app
python app.py
```

### Verification

- Frontend: http://localhost:5174
- Backend: http://localhost:5000
- Both should run without errors

---

## Making Changes

### Branch Naming

Use descriptive names:
- **Feature:** `feature/add-dark-mode`
- **Bug Fix:** `bugfix/fix-login-crash`
- **Documentation:** `docs/update-readme`
- **Refactor:** `refactor/optimize-api-calls`

### Commit Frequently

Make small, logical commits:

```bash
git commit -m "Add feature X"
git commit -m "Fix bug in component Y"
git commit -m "Update documentation"
```

### Keep Updated

```bash
# Fetch latest upstream
git fetch upstream

# Rebase on main
git rebase upstream/main
```

---

## Submitting Changes

### Before Submitting

1. **Test your changes**
   ```bash
   npm run lint
   npm run build
   ```

2. **Update documentation**
   - Update README if behavior changed
   - Add comments for complex logic
   - Update CHANGELOG if applicable

3. **Verify no secrets**
   ```bash
   # Ensure no .env or API keys in commits
   git diff --cached | grep -i 'secret\|key\|password'
   ```

4. **Sync with main**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### Create Pull Request

1. Push your branch
   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to GitHub and create Pull Request

3. Fill in PR template:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Related Issues
   Fixes #123

   ## Testing
   How was this tested?

   ## Screenshots (if applicable)
   ```

4. Submit for review

### PR Guidelines

**Good PRs are:**
- ✅ Focused on single feature/fix
- ✅ Small and easy to review
- ✅ Well-tested
- ✅ Documented
- ✅ Follow coding standards

**Avoid:**
- ❌ Large monolithic changes
- ❌ Mixing multiple features
- ❌ No tests or documentation
- ❌ Hardcoded values/secrets

---

## Coding Standards

### JavaScript/React

```javascript
// ✅ Good
const handleClick = () => {
  setIsLoading(true);
  fetchData()
    .then(data => setData(data))
    .catch(error => console.error(error));
};

// ✗ Bad
const handleClick = ()=>{setIsLoading(true);fetchData().then(data=>setData(data)).catch(error=>console.error(error));}
```

**Standards:**
- Use modern ES6+ syntax
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code style
- Use camelCase for variables
- Use PascalCase for components
- Use UPPER_SNAKE_CASE for constants

### Python

```python
# ✅ Good
def fetch_api_data(endpoint, timeout=30):
    """Fetch data from API endpoint with timeout."""
    try:
        response = requests.get(endpoint, timeout=timeout)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as error:
        logger.error(f"API error: {error}")
        return None

# ✗ Bad
def fetch(e,t=30):
    return requests.get(e,timeout=t).json()
```

**Standards:**
- Use snake_case for functions/variables
- Add docstrings to functions
- Add type hints where helpful
- Keep lines under 88 characters
- Use meaningful names
- Add error handling

### CSS/Tailwind

```jsx
// ✅ Good
<button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
  Click me
</button>

// ✗ Bad
<button style={{padding: '10px', backgroundColor: 'blue'}}>Click me</button>
```

**Standards:**
- Use Tailwind classes
- Use utility-first approach
- Keep components small
- Avoid inline styles
- Use consistent spacing

---

## Commit Messages

### Format

```
<type>: <subject>

<body>

<footer>
```

### Type

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation
- **style:** Code style (formatting)
- **refactor:** Code refactoring
- **perf:** Performance improvement
- **test:** Test additions
- **chore:** Build/dependency changes

### Example

```
feat: Add dark mode toggle

- Add theme context provider
- Implement theme switcher component
- Update CSS variables for dark theme
- Add theme persistence to localStorage

Fixes #42
```

### Subject Line
- Imperative mood ("Add", not "Added")
- Don't capitalize first letter
- No period at end
- Under 50 characters

### Body
- Explain WHAT and WHY, not HOW
- Reference issue numbers (#123)
- Wrap at 72 characters
- Separate from subject with blank line

---

## Testing

### Frontend Tests

```bash
# Run tests
npm run test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

### Backend Tests

```bash
# Run tests
python -m pytest

# Run specific test
python -m pytest tests/test_api.py

# Run with coverage
pytest --cov=.
```

### Manual Testing

1. **Test in development**
   ```bash
   npm run dev
   python app.py
   ```

2. **Test in production build**
   ```bash
   npm run build
   npm run preview
   ```

3. **Test on mobile**
   - Use device emulator or real device
   - Test on iOS Safari and Android Chrome
   - Test responsive design

---

## Documentation

### Update README
- Document new features
- Update installation steps if changed
- Add API endpoint documentation

### Add Inline Comments
```javascript
// Good comment: explains WHY, not WHAT
// Use setTimeout to debounce rapid API calls
setTimeout(() => {
  handleSearch();
}, 300);

// Bad comment: explains WHAT code does
// Set timeout for 300ms
setTimeout(() => {
  handleSearch();
}, 300);
```

### Update CHANGELOG
```markdown
## [1.1.0] - 2025-11-02

### Added
- New feature X
- Documentation for feature Y

### Fixed
- Bug in component Z

### Changed
- Improved performance of API calls
```

---

## Resources

- [GitHub Docs](https://docs.github.com/)
- [Git Cheat Sheet](https://github.github.com/training-kit/downloads/github-git-cheat-sheet.pdf)
- [React Best Practices](https://react.dev/learn)
- [Python PEP 8](https://pep8.org/)

---

## Questions?

- 💬 GitHub Discussions
- 🐛 GitHub Issues
- 📧 Email: dev@squirtvana.example

---

**Thank you for contributing! Your efforts make Squirtvana better for everyone.** 🙏
