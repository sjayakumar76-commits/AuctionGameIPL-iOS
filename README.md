# AuctionGameIPLiOS

This folder contains a SwiftUI iOS port of the Android project in `AuctionGameIPL`.

## What is included

- A minimal Xcode project: `AuctionGameIPLiOS.xcodeproj`
- SwiftUI app source using the same Google Script endpoints as the Android app
- Asset catalog with a copied hero image and generated app icons

## Open on macOS

1. Copy `AuctionGameIPLiOS` to a Mac with Xcode 15 or newer.
2. Open `AuctionGameIPLiOS.xcodeproj`.
3. In Xcode, change the signing team and bundle identifier.
4. Build and run on an iPhone simulator or device.
5. Archive from Xcode to produce the `.ipa`.

## Command line archive

After setting signing in Xcode once, you can archive from Terminal on the Mac:

```bash
xcodebuild \
  -project AuctionGameIPLiOS.xcodeproj \
  -scheme AuctionGameIPLiOS \
  -configuration Release \
  -destination generic/platform=iOS \
  -archivePath build/AuctionGameIPLiOS.xcarchive \
  archive
```

Then export:

```bash
xcodebuild -exportArchive \
  -archivePath build/AuctionGameIPLiOS.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions-AdHoc.plist
```

## Codemagic without a Mac

This repository root now includes `codemagic.yaml`.

1. Push the `AuctionGameIPLiOS` folder to GitHub, GitLab, or Bitbucket as its own repository, or make this folder the repository root.
2. Add the repository to Codemagic.
3. In Codemagic Team integrations, add an App Store Connect API key and name it `CM_APP_STORE_CONNECT`.
4. The project is already set to bundle identifier `com.jk.auctiongameipl`.
5. In Codemagic code signing settings, fetch or upload the matching certificate and provisioning profile for that bundle identifier.
6. Run the `ios-signed-ipa` workflow to produce a signed `.ipa`.

If you only want a cloud compile check first, run `ios-simulator`. That produces a simulator `.app`, not an installable `.ipa`.

## Notes

- The Android app contains several repeated Activities with hard-coded index windows into the same JSON payload. The iOS version keeps the same endpoint behavior but implements it with reusable SwiftUI screens.
- `Fixed 6`, `Week 1` to `Week 9`, `Auction Rules`, and `Winning Prizes` intentionally mirror the Android logic, including its unusual field mappings.
