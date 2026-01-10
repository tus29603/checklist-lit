# Google AdMob Setup Notes

## ✅ FIXED: App ID Crash Issue

The crash has been **fixed** by setting a proper test App ID. The app should now run without crashing.

### Current App ID Setting (Production App ID)
The project is configured with your **production App ID**:
```
ca-app-pub-8853742472105910~7060661899
```

**✅ This is your production App ID from your AdMob console.**

### App ID Configuration:

The App ID is automatically added to Info.plist via a build script phase:
- **App ID:** `ca-app-pub-8853742472105910~7060661899`
- **Location:** Added by shell script build phase "Add GADApplicationIdentifier"
- **Script Location:** `project.pbxproj` - PBXShellScriptBuildPhase section

**Note:** The App ID is automatically injected into the generated Info.plist during the build process.

### Testing:
- Use test ad unit ID during development: `ca-app-pub-3940256099942544/2934735716` ✅ (Already configured)
- Switch to production when ready: `ca-app-pub-8853742472105910/4965067318`

### Common Issues:
- **Crash on launch:** Usually means App ID is missing or incorrect
- **No ads showing:** Check ad unit ID is correct and App ID matches your AdMob account
- **SDK initialization errors:** Check console logs for specific error messages

## Code Changes Made:
- Added Google Mobile Ads SDK via Swift Package Manager
- Created `AdMobBannerView.swift` component
- Initialized SDK in `ChecklistLiteApp.swift`
- Added banner at bottom of `ContentView`
- Added safer initialization and error handling

