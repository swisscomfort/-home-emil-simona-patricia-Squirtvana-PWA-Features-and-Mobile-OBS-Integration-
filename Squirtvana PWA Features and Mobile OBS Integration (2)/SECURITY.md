# Security Audit & Best Practices

This document outlines security measures and best practices for Squirtvana PWA.

## Security Audit Checklist

### 1. API Key Management

- [x] API keys stored in `.env` file (never committed)
- [x] `.env` file in `.gitignore`
- [x] `.env.example` provided as template
- [x] Environment variables used in code
- [x] Keys rotated regularly (recommended: monthly)
- [ ] Use HashiCorp Vault for secrets management (production)
- [ ] Implement key rotation automation

**Action Items:**
1. ✅ Never commit real `.env` file
2. ✅ Use `.env.example` for documentation
3. ✅ Rotate API keys monthly
4. 🔄 Plan key rotation schedule

### 2. HTTPS/TLS

- [x] Frontend served over HTTPS (recommended)
- [x] Backend API over HTTPS (required for production)
- [x] Certificate from trusted CA (Let's Encrypt)
- [x] Certificate validation enabled
- [ ] HSTS header set (Strict-Transport-Security)
- [ ] TLS 1.2+ required

**Implementation:**
```python
@app.after_request
def set_security_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    return response
```

### 3. Authentication & Authorization

**Current Status:**
- ⚠️ No authentication required (PWA is stateless)
- ⚠️ Optional: Implement for future features

**Future Implementation:**
```python
from flask_login import LoginManager, login_required

login_manager = LoginManager()
login_manager.init_app(app)

@app.route('/api/protected')
@login_required
def protected_endpoint():
    return jsonify({'data': 'only for authenticated users'})
```

### 4. Input Validation

**Frontend:**
```javascript
// Validate inputs before sending
const validateInput = (text) => {
  if (!text || text.trim().length === 0) {
    throw new Error('Input cannot be empty');
  }
  if (text.length > 5000) {
    throw new Error('Input too long (max 5000 chars)');
  }
  return text.trim();
};
```

**Backend:**
```python
from flask import request
from datetime import datetime

@app.route('/api/gpt/generate', methods=['POST'])
def generate():
    data = request.get_json()
    
    # Validate input
    if not data or 'prompt' not in data:
        return jsonify({'error': 'Missing prompt'}), 400
    
    prompt = data['prompt']
    
    # Sanitize
    if len(prompt) > 5000:
        return jsonify({'error': 'Prompt too long'}), 400
    
    if not isinstance(prompt, str):
        return jsonify({'error': 'Invalid input type'}), 400
    
    # Process safely
    return generate_content(prompt)
```

### 5. XSS Prevention

**React:**
```javascript
// ✅ Safe - React auto-escapes by default
<div>{userInput}</div>

// ⚠️ Dangerous - Use only for trusted HTML
<div dangerouslySetInnerHTML={{__html: userInput}} />

// ✅ Safe alternative - use libraries
import DOMPurify from 'dompurify';
<div>{DOMPurify.sanitize(userInput)}</div>
```

### 6. CSRF Protection

**Backend:**
```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

# CSRF enabled by default for all POST requests
@app.route('/api/action', methods=['POST'])
@csrf.protect
def action():
    return jsonify({'status': 'ok'})
```

**Frontend:**
```javascript
// Include CSRF token in requests
async function apiCall(endpoint, method = 'POST', data = {}) {
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  
  return fetch(endpoint, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'X-CSRFToken': token
    },
    body: JSON.stringify(data)
  });
}
```

### 7. Rate Limiting

**Backend with Flask-Limiter:**
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/gpt/generate', methods=['POST'])
@limiter.limit("10 per hour")  # 10 requests per hour for expensive API
def generate():
    return generate_content()
```

### 8. Dependency Security

**Regular Updates:**
```bash
# Check for vulnerabilities
npm audit
npm audit fix

# Python dependencies
pip install --upgrade pip
pip check
pip install safety
safety check
```

**GitHub Dependabot:**
1. Go to **Settings** → **Code security and analysis**
2. Enable **Dependabot alerts**
3. Enable **Dependabot security updates**

### 9. Secrets Scanning

**Pre-commit Hook:**
```bash
# Install
pip install pre-commit detect-secrets

# Setup
detect-secrets scan --all-files > .secrets.baseline
pre-commit install
pre-commit run --all-files
```

### 10. CORS Configuration

**Strict CORS:**
```python
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://your-domain.com", "https://www.your-domain.com"],
        "methods": ["GET", "POST"],
        "allow_headers": ["Content-Type"],
        "supports_credentials": True
    }
})
```

---

## Data Security

### Data in Transit

- ✅ HTTPS for all connections
- ✅ TLS 1.2+ minimum
- ✅ Certificate pinning (optional for mobile)
- ✅ No sensitive data in URLs

### Data at Rest

- ✅ Local storage encryption (device OS handles)
- ✅ Sensitive data in memory only
- ✅ Clear cache after sensitive operations
- ⚠️ No persistent storage of API keys

**Browser Storage:**
```javascript
// ❌ Avoid storing sensitive data
localStorage.setItem('apiKey', key);

// ✅ Use session memory (cleared on tab close)
sessionStorage.setItem('token', token);

// ✅ Best: IndexedDB with encryption
import * as crypto from 'crypto-js';
const encrypted = crypto.AES.encrypt(key, password);
```

### Backups

- ⚠️ Device backups may include app config
- ✅ Users responsible for backup security
- ✅ No automatic cloud backups of credentials

---

## Third-Party Security

### OpenRouter
- Review: https://openrouter.ai/security
- Risk: Medium (GPT data transmission)
- Mitigation: HTTPS only, no sensitive PII

### ElevenLabs
- Review: https://elevenlabs.io/security
- Risk: Low (voice synthesis, no logging)
- Mitigation: Use standard voices, no private audio

### Telegram
- Review: https://telegram.org/privacy
- Risk: Low (notifications only)
- Mitigation: No sensitive data in messages

---

## Privacy Compliance

### GDPR (EU)

- ✅ Minimal data collection
- ✅ No data storage on servers
- ✅ Right to deletion (app uninstall)
- ✅ User control of data
- ✅ Privacy policy in place

### CCPA (California)

- ✅ No personal information sale
- ✅ User control of data
- ✅ Right to know, delete, opt-out
- ✅ Privacy policy provided

### COPPA (Children's Data)

- ✅ No targeting of under-13s
- ✅ No behavioral tracking
- ⚠️ Age gate recommended (future)

---

## Incident Response

### Potential Incidents

1. **API Key Exposure**
   - Immediately revoke the key
   - Generate new key
   - Rotate in `.env`
   - No need to rebuild app (uses env)

2. **Vulnerability Discovered**
   - Assess impact and severity
   - Develop fix
   - Test thoroughly
   - Release security patch
   - Notify users

3. **Data Breach**
   - No user data stored on servers
   - Device data is user responsibility
   - Notify affected parties
   - Update incident report

### Response Plan

```
1. Detect → Report to security team
2. Assess → Evaluate severity
3. Contain → Stop further impact
4. Eradicate → Fix root cause
5. Recover → Restore normal operation
6. Communicate → Notify users
7. Improve → Prevent recurrence
```

---

## Security Testing

### Manual Testing

```bash
# Check for secrets in code
grep -r "api_key\|password\|secret" src/

# Scan for vulnerabilities
npm audit
safety check

# Test HTTPS
curl -I https://your-domain.com
```

### Automated Testing

```bash
# OWASP ZAP
docker run -t owasp/zap2docker-stable:latest zap-baseline.py -t https://your-domain.com

# Snyk
npm install -g snyk
snyk test
```

### Penetration Testing

- Recommended: Annual security audit
- Estimated cost: $2,000-5,000
- Providers: NCC Group, Trail of Bits, Synopsys

---

## Security Headers

**Recommended Headers:**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: accelerometer=(), camera=(), microphone=(), payment=()
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'
```

---

## Security Updates

### Monthly Tasks
- [ ] Check npm/pip for updates
- [ ] Review security advisories
- [ ] Test updates in staging
- [ ] Deploy to production

### Quarterly Tasks
- [ ] Audit API usage
- [ ] Review access logs
- [ ] Update security policies
- [ ] Penetration test (annual)

### Annual Tasks
- [ ] Full security audit
- [ ] Dependency audit
- [ ] Code review
- [ ] Incident review

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [npm Security Best Practices](https://docs.npmjs.com/secure/start)
- [Flask Security](https://flask.palletsprojects.com/security/)

---

## Security Contacts

- **Report Security Issues:** security@squirtvana.example
- **GitHub Security Advisory:** https://github.com/yourusername/squirtvana/security/advisories
- **Responsible Disclosure:** Use GitHub private vulnerability reporting

---

**Last Updated:** November 2, 2025  
**Next Audit Scheduled:** May 2, 2026

