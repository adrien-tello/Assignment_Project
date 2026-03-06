# App Icon Setup Instructions

## Quick Setup

1. **Create App Icon:**
   - Go to: https://www.canva.com or https://www.figma.com
   - Create a 1024x1024px image
   - Design: Purple gradient background (#6C63FF) with white graduation cap icon
   - Export as PNG

2. **Save Icon:**
   - Save the image as `app_icon.png`
   - Place it in: `assets/icons/app_icon.png`

3. **Generate Icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Done!** Your app now has custom icons on Android and iOS.

## Alternative: Use Online Generator

1. Visit: https://icon.kitchen
2. Upload your 1024x1024 icon
3. Download Android and iOS icons
4. Replace files in:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Icon Design Recommendations

- **Background:** Purple gradient (#6C63FF to #4CAF50)
- **Icon:** White graduation cap or calculator
- **Style:** Flat, modern, minimal
- **Format:** PNG with transparency
- **Size:** 1024x1024px minimum
