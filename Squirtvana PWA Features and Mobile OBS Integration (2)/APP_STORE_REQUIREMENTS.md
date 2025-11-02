# App Store Requirements Checklist

Complete checklist for Apple App Store compliance and submission.

## Pre-Submission Checklist

### App Functionality

- [ ] App launches without crashes
- [ ] All features work as described
- [ ] No error messages on first launch
- [ ] Touch targets are minimum 44×44 points
- [ ] All text is readable without zooming
- [ ] Orientation changes work properly
- [ ] App handles network errors gracefully
- [ ] Offline mode works (if applicable)

### User Interface

- [ ] Follows iOS design guidelines
- [ ] Uses native iOS components (or looks consistent)
- [ ] Status bar visibility correct
- [ ] Safe area respected
- [ ] Keyboard handling proper
- [ ] No misleading button behavior
- [ ] Back/navigation intuitive

### Content

- [ ] No placeholder content
- [ ] All strings properly localized (if needed)
- [ ] No hardcoded URLs (use configuration)
- [ ] Icons and images are professional
- [ ] No broken links or references
- [ ] All functionality described works

### Privacy & Security

- [ ] Privacy policy present and accessible
- [ ] Privacy policy link working
- [ ] Data practices disclosed
- [ ] Secure connections (HTTPS) used
- [ ] No tracking without user consent
- [ ] Permissions requested properly

### Performance

- [ ] App launches in <5 seconds
- [ ] Responds to touches within 100ms
- [ ] No battery drain issues
- [ ] Memory usage reasonable
- [ ] Smooth scrolling/animations
- [ ] No crashes on background/foreground

---

## Content Rating

### Fill Rating Questionnaire

1. **Contests**
   - No real gambling: ✅ No
   - No contests of chance: ✅ No

2. **Frequent/Intense**
   - No violence: ✅ No
   - No profanity: ✅ Depends (review content policy)
   - No alcohol/tobacco: ✅ No
   - No sexual content: ✅ No

3. **Infrequent/Mild**
   - No profanity: ✅ No
   - No realistic violence: ✅ No
   - No sexual content: ✅ No

**Resulting Rating:** Likely **4+** (if no profanity)

---

## App Metadata

### App Name

- **Primary Name:** Squirtvana (required)
- **Max Characters:** 30
- **Subtitle (Optional):** PWA Mobile Controller (max 30 chars)
- **Avoid:**
  - [ ] Emojis only
  - [ ] Misleading keywords
  - [ ] Competitor names
  - [ ] Generic words like "App" or "Pro"

### Category

**Select appropriate category:**
- **Primary:** Entertainment
- **Secondary:** Utilities (optional)
- **Avoid:** Misleading categories

### Description

**Requirements:**
- Max 4,000 characters
- First 160 chars appear in search
- Highlight key features
- Include call-to-action
- No promotional language

**Template:**
```
Squirtvana PWA - Mobile Streaming Control Center

Control your OBS streams, generate AI-powered content, 
and monitor system performance from your mobile device.

Key Features:
• OBS Scene Switching - Real-time stream control
• AI Content Generation - GPT-powered creativity
• Text-to-Speech - Realistic voice synthesis
• System Monitoring - Live performance tracking
• Offline Support - Works without internet

Requirements:
- iOS 14.0 or later
- Internet connection (for full features)

🚀 Start streaming like a pro today!
```

### Keywords

**Enter up to 30 keywords:**
- streaming
- obs
- ai
- content
- generator
- live
- mobile
- control
- pwa
- web app

### Support URLs

- **Support URL:** https://github.com/yourusername/squirtvana/issues
- **Privacy Policy URL:** https://your-domain.com/privacy
- **Marketing URL (Optional):** https://your-domain.com

### Promotional Text

- Max 170 characters
- Appears above description
- Update without app review

Example:
```
New feature: AI content generation with custom voices!
```

---

## Screenshots & Preview

### Screenshot Requirements

**Sizes:**
- 5.5-inch (1242×2208 px) - All screenshots required
- 6.5-inch (1284×2778 px) - At least 2 required
- iPad (2048×2732 px) - Optional but recommended

**Content:**
- Show app UI (not just artwork)
- Use real text, not Lorem Ipsum
- Highlight key features
- Include captions (20 chars max)
- Professional appearance

**Tools:**
- Simulator screenshots: Cmd+S
- Screenshot editing: Figma, Sketch
- Frame generator: AppMockUp, Previewed

### Screenshot Examples

```
Screenshot 1: Launch Screen
Caption: "Control Your Streams"

Screenshot 2: Main Interface
Caption: "Manage OBS Scenes"

Screenshot 3: AI Generator
Caption: "AI-Powered Content"

Screenshot 4: System Monitoring
Caption: "Real-Time Stats"

Screenshot 5: Text-to-Speech
Caption: "Realistic Voices"
```

### Preview Video (Optional)

- **Duration:** Up to 30 seconds
- **Format:** MP4 or MOV
- **Resolution:** 1242×2208 (or higher)
- **Content:** Demonstrate key features
- **Audio:** Optional but recommended
- **Subtitles:** Helpful for accessibility

**Example Script:**
```
0-5s: Launch and main interface
5-10s: OBS scene switching demo
10-15s: AI content generation
15-20s: Text-to-speech feature
20-25s: System monitoring
25-30s: Call-to-action
```

---

## Build Configuration

### Version

**Format:** X.Y.Z (semantic versioning)
- **X:** Major version (breaking changes)
- **Y:** Minor version (new features)
- **Z:** Patch version (bug fixes)

Example: 1.0.0

### Build Number

Sequential number for each build submitted.
Example: 1, 2, 3, etc.

### Supported Devices

- [ ] iPhone 6s and later
- [ ] iPad (5th generation and later)
- [ ] iOS 14.0 minimum

### Orientation

- [x] Portrait
- [x] Landscape
- [x] Portrait Upside Down (optional)
- [x] Landscape Left
- [x] Landscape Right

---

## Privacy & Legal

### Privacy Policy

**Requirements:**
- Publicly accessible URL (HTTPS)
- Clear and concise language
- Address these points:
  1. What data is collected
  2. How data is used
  3. Third-party sharing
  4. User rights
  5. Contact information

**Example sections:**
- Data Collection
- Use of Information
- Third-Party Services
- Security
- Changes to Policy
- Contact Us

### Terms of Service

- Not required but recommended
- Address usage restrictions
- Liability limitations
- User responsibilities

### Data Privacy

**Declare:**
- [ ] Does app use IDFA (Ad tracking)
- [ ] Does app require health data
- [ ] Does app access camera/microphone
- [ ] Does app collect contacts/calendar
- [ ] Does app collect photos/location

For Squirtvana: ✅ None of the above (unless added)

---

## Compliance Guidelines

### Prohibited Content

❌ Do NOT include:
- Profanity (unless age-appropriate)
- Graphic violence
- Gambling or lotteries
- Sexual content
- Illegal activities
- Misleading functionality
- Unrealistic claims
- Copyright infringement
- Trademark infringement

### Acceptable Content

✅ DO include:
- Clear descriptions of features
- Realistic screenshots
- Professional UI
- Honest performance metrics
- Proper attribution
- Age-appropriate content

---

## Review Guidelines Summary

### Common Rejection Reasons

1. **Crashes on Launch**
   - Solution: Thoroughly test on real devices

2. **Incomplete Functionality**
   - Solution: Ensure all features work as described

3. **Missing Privacy Policy**
   - Solution: Add and link in app metadata

4. **Misleading App Description**
   - Solution: Accurately describe features

5. **Poor User Interface**
   - Solution: Follow Apple's HIG guidelines

6. **Excessive Advertisements**
   - Solution: Limit ads, ensure UX not compromised

7. **Unauthorized Use of APIs**
   - Solution: Get proper permissions

### Quick Fix Checklist

```
❌ App Rejected?
├─ Check rejection reason carefully
├─ Reproduce issue on real device
├─ Fix identified problems
├─ Increment build number
├─ Retest thoroughly
├─ Provide detailed response
└─ Resubmit
```

---

## Submission Timeline

- **Submission:** Submit via App Store Connect
- **Initial Review:** 24-48 hours
- **Decision:** Approved, Rejected, or Revision needed
- **Approved:** Available on App Store immediately
- **Rejected:** Fix issues, resubmit

---

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [HIG - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Common App Rejections](https://developer.apple.com/forums/)

---

## Submission Checklist

**Final Review Before Submission:**

- [ ] App runs without crashes
- [ ] All features functional
- [ ] Privacy policy accessible
- [ ] Screenshots professional (5.5" and 6.5")
- [ ] Description accurate and compelling
- [ ] Keywords relevant
- [ ] Support URL active
- [ ] Build number incremented
- [ ] No hardcoded API keys
- [ ] All URLs use HTTPS
- [ ] Age rating selected
- [ ] Pricing set (free or paid)
- [ ] Ready to distribute checked
- [ ] No beta or placeholder content

---

## After Approval

### Monitoring

- Monitor user reviews
- Respond to feedback
- Track crashes/issues
- Monitor performance metrics

### Updates

- Version 1.1.0: Bug fixes
- Version 1.2.0: New features
- Version 2.0.0: Major redesign

### User Communication

- In-app notifications for updates
- Release notes explaining changes
- Social media announcements
- Email to users (if applicable)

---

**Good luck with your App Store submission!** 🚀

For questions: security@squirtvana.example
