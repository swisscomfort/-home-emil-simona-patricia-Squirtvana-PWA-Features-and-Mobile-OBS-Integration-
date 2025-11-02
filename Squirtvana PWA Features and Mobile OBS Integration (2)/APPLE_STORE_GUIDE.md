# Apple App Store Distribution Guide for Squirtvana PWA

This guide explains how to distribute Squirtvana PWA through the Apple App Store using a native wrapper approach.

## Overview

Since Squirtvana is a Progressive Web App (PWA), there are three distribution options:

1. **Web Distribution** - Direct Safari URL (Easiest)
2. **Web App Wrapper** - Native iOS app wrapping the PWA (Recommended)
3. **Enterprise Distribution** - Internal iOS deployment

This guide focuses on **Option 2: Web App Wrapper**, which provides the best user experience.

## Prerequisites

- Mac with Xcode 14.0 or later
- Apple Developer Account ($99/year)
- iOS 14.0+ compatible device/simulator
- Squirtvana PWA deployed on HTTPS URL

## Option 1: Direct PWA on iOS Safari (Fastest)

### Steps

1. **Deploy PWA to HTTPS**
   - Your PWA must be accessible via HTTPS
   - Configure `manifest.json` properly
   - Test in Safari on iPad/iPhone

2. **Share with Users**
   - Users visit your website in Safari
   - Tap **Share** → **Add to Home Screen**
   - PWA installs as standalone app

### Advantages
- ✅ No App Store submission required
- ✅ Instant updates (no review process)
- ✅ No 30% fee
- ✅ Full control of app

### Disadvantages
- ❌ Not discoverable in App Store
- ❌ Users must manually install
- ❌ Less visibility

## Option 2: Native iOS Wrapper (Recommended for App Store)

### Prerequisites

1. **Create Xcode Project**
   ```bash
   # Install Xcode from Mac App Store
   xcode-select --install
   ```

2. **Get Development Certificates**
   - Sign in to Xcode with Apple ID
   - Navigate to **Xcode → Preferences → Accounts**
   - Click **Manage Certificates**
   - Create iOS Development Certificate

### Step-by-Step Setup

#### 1. Create Xcode Project

1. Open Xcode
2. **File** → **New** → **Project**
3. Select **iOS** → **App**
4. Configure:
   - **Product Name:** Squirtvana
   - **Organization:** Your Name/Company
   - **Bundle ID:** `com.yourname.squirtvana`
   - **Language:** Swift
   - **User Interface:** SwiftUI
5. Click **Create**

#### 2. Configure App Settings

1. Select **Squirtvana** project in sidebar
2. Go to **General** tab
3. Set:
   - **Minimum Deployments:** iOS 14.0
   - **Supported Orientations:** Portrait, Landscape
   - **App Icons:** Add custom icons (see below)
   - **Launch Screen:** Configure splash screen

#### 3. Add App Icons

**Required Icon Sizes:**
- 1024×1024 px (App Store)
- 180×180 px (iPhone)
- 152×152 px (iPad)
- 167×167 px (iPad Pro)
- Additional sizes in `.xcassets`

**Process:**
1. In Xcode, select **Assets.xcassets**
2. Add **App Icon Set**
3. Drag icons to correct sizes
4. Or use online generator: [App Icon Generator](https://www.appicon.co/)

#### 4. Create WebView Component

Create `WebView.swift`:

```swift
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update webview if needed
    }
}

struct ContentView: View {
    let pwaURL = URL(string: "https://your-squirtvana-url.com")!
    
    var body: some View {
        ZStack {
            WebView(url: pwaURL)
                .ignoresSafeArea()
            
            // Optional: Add splash screen
        }
    }
}
```

#### 5. Configure Info.plist

Add to **Info.plist**:

```xml
<dict>
    <!-- PWA Configuration -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>your-squirtvana-url.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <false/>
                <key>NSIncludesSubdomains</key>
                <true/>
            </dict>
        </dict>
    </dict>
    
    <!-- Orientation -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- Status Bar -->
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleDarkContent</string>
</dict>
```

#### 6. Build and Test

```bash
# Build for simulator
xcodebuild -scheme Squirtvana -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use Xcode UI:
# Product → Scheme → iPhone 15 (or your device)
# Product → Run
```

## App Store Submission Process

### 1. Create App Store Connect Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. **Apps** → **New App**
3. Fill in details:
   - **Name:** Squirtvana
   - **Bundle ID:** com.yourname.squirtvana
   - **SKU:** Your internal identifier
   - **Platform:** iOS
4. Click **Create**

### 2. Fill App Information

#### General Information
- **Default Language:** English
- **Category:** Entertainment (or Utilities)
- **Subcategory:** Streaming Media

#### Descriptive Metadata
- **Description:** (max 4000 chars)
  ```
  Squirtvana is a powerful mobile streaming control center.
  Control OBS streams, generate AI-powered content, and monitor
  system performance directly from your mobile device.
  
  Features:
  • OBS Stream Control - Scene switching and monitoring
  • AI Content Generation - GPT-powered content creation
  • Text-to-Speech - Realistic voice synthesis
  • System Monitoring - Live CPU, RAM, disk tracking
  • Offline Support - Works without internet
  ```

- **Keywords:** streaming, obs, ai, content, generator, live
- **Support URL:** https://your-domain.com/support
- **Privacy Policy URL:** https://your-domain.com/privacy

### 3. Screenshots & Preview

**iPhone Screenshots (Required):**
- 5.5-inch display (1242×2208 px) - at least 2 required
- 6.5-inch display (1284×2778 px) - at least 2 required

**iPad Screenshots (Optional):**
- 12.9-inch display (2048×2732 px)

**App Preview Video (Optional):**
- MP4, 30 seconds max
- Demonstrates key features

**Process:**
1. Screenshot in simulator: **Cmd + S**
2. Use screenshots to highlight features
3. Add text overlays explaining functionality
4. Tools: Screenshot Creator, Previewed, AppLaunchpad

### 4. Build Configuration

1. In Xcode, select **Product** → **Archive**
2. Validate archive (or export for ad-hoc)
3. Upload to App Store Connect

### 5. App Review Guidelines

Apple will review your app against these criteria:

✅ **Must Pass:**
- App must work as described
- HTTPS for all connections
- Proper privacy policy
- No crashes or bugs
- Appropriate content rating

⚠️ **Common Rejection Reasons:**
- ❌ Unreliable or unstable functionality
- ❌ Missing privacy policy
- ❌ Misleading app description
- ❌ Technical issues on first launch
- ❌ Objectionable content (check naming/description)

### 6. Submit for Review

1. In App Store Connect, go to app
2. **Prepare for Submission**
3. Fill in version details
4. Select builds to review
5. Add release notes
6. Click **Submit for Review**

**Review Timeline:** 24-48 hours typically

## Version Updates

### Publishing Updates

1. Increment version in Xcode
2. Create new build
3. Archive and upload
4. Submit new version for review
5. Reviews typically faster for updates

### Automatic Updates

Since the wrapper loads from your HTTPS URL, PWA updates happen automatically when users open the app:

1. Update PWA code on server
2. Users get latest version next launch
3. No App Store review needed for PWA updates
4. Only Xcode wrapper needs review updates

## Metadata & App Store Optimization

### App Icon Requirements

```
App Icon Sizes:
├── 1024×1024 (App Store)
├── 180×180 (iPhone)
├── 152×152 (iPad)
├── 167×167 (iPad Pro)
├── 120×120 (iPhone small)
└── 40×40 (Spotlight)
```

### App Name Optimization

**Primary Name:** Squirtvana (up to 30 chars)
**Subtitle:** PWA Mobile Controller (up to 30 chars)

### Content Rating

1. In App Store Connect, go to **App Privacy & Security**
2. Fill rating questionnaire
3. Typical rating: **4+** (no objectionable content)

## Privacy Policy

**Required sections:**
1. Data collection practices
2. Third-party APIs (OpenRouter, ElevenLabs)
3. User data usage
4. Security measures
5. Contact information

**Template:**
```markdown
# Privacy Policy - Squirtvana

## Data Collection
We collect:
- No personal data by default
- Optional user preferences (stored locally)

## Third-Party Services
- OpenRouter (AI content) - See their privacy policy
- ElevenLabs (text-to-speech) - See their privacy policy

## Security
- All data transmitted via HTTPS
- No data stored on servers
- Local storage only
```

## Common Issues & Solutions

### Issue: Build fails with "No developer certificate"
**Solution:** Add development certificate in Xcode Preferences

### Issue: PWA not loading in app
**Solution:** Ensure HTTPS, check Info.plist, verify URL accessibility

### Issue: App rejected for "Misleading functionality"
**Solution:** Ensure description accurately matches features

### Issue: Cannot upload to App Store Connect
**Solution:** Update Xcode, verify Apple ID permissions, rebuild archive

## Alternative: Web App Distribution

If App Store submission is too complex, consider:

1. **TestFlight** - Beta distribution (easier process)
2. **Enterprise** - Internal distribution (requires enterprise account)
3. **Direct PWA** - Users manually add to home screen (easiest)

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Next Steps

1. ✅ Deploy PWA to HTTPS URL
2. ✅ Create Xcode project
3. ✅ Configure app icons & splash screen
4. ✅ Test on simulator
5. ✅ Create App Store Connect record
6. ✅ Submit for review
7. ✅ Monitor review status

---

For questions or issues, check the [main README.md](./README.md) or GitHub Issues.
