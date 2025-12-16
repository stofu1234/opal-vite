# PWA Icons

This directory should contain the following icon files for the PWA:

- `icon-192.png` - 192x192 pixels
- `icon-512.png` - 512x512 pixels

## Creating Icons

You can create these icons using:

1. **Online Tools:**
   - [PWA Image Generator](https://www.pwabuilder.com/imageGenerator)
   - [Favicon Generator](https://realfavicongenerator.net/)

2. **Design Tools:**
   - Figma, Sketch, Adobe XD
   - Export at 192x192 and 512x512 px

3. **Simple Placeholder:**
   Use a solid color square with your app name/logo

## Requirements

- **Format**: PNG (recommended) or SVG
- **Sizes**: 192x192 and 512x512 minimum
- **Purpose**:
  - 192x192: Home screen icon
  - 512x512: Splash screen and high-DPI displays

## Quick Placeholder

For testing, you can use any PNG images of the correct sizes. The vite-plugin-pwa will use these for the manifest.

## Note

The PWA will still work without icons, but you'll see broken image icons on the install prompt and home screen.
