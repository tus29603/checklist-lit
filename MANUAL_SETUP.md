# Manual AdMob App ID Setup Instructions

## Quick Fix: Add App ID in Xcode

Since the automated script approach isn't persisting, here's how to manually add the App ID:

### Step 1: Open Xcode Project Settings
1. Open `Checklist-Lite.xcodeproj` in Xcode
2. Select the **project** (blue icon) in the Navigator
3. Select the **"Checklist-Lite"** target

### Step 2: Add App ID in Info Tab
1. Click the **"Info"** tab
2. In the "Custom iOS Target Properties" section, click the **"+"** button
3. Add a new row with:
   - **Key:** `GADApplicationIdentifier`
   - **Type:** `String`  
   - **Value:** `ca-app-pub-8853742472105910~7060661899`

### Step 3: Verify
1. Clean build folder: `Product` → `Clean Build Folder` (Shift+Cmd+K)
2. Build and run the app
3. Check that the error is gone

---

## Alternative: Create Manual Info.plist

If you prefer using a manual Info.plist file:

1. **Create Info.plist:**
   - Right-click `Checklist-Lite` folder → "New File..."
   - Choose "Property List"
   - Name it `Info.plist`
   - Add the following key-value pair:
     ```xml
     <key>GADApplicationIdentifier</key>
     <string>ca-app-pub-8853742472105910~7060661899</string>
     ```
   
2. **Configure Project:**
   - In Build Settings, set:
     - `GENERATE_INFOPLIST_FILE = NO`
     - `INFOPLIST_FILE = Checklist-Lite/Info.plist`
   
3. **Important:** If Info.plist appears in "Copy Bundle Resources", remove it from there (it should only be processed, not copied).

---

## Current App ID
- **Production App ID:** `ca-app-pub-8853742472105910~7060661899`
- **Location:** Should be in Info.plist with key `GADApplicationIdentifier`

