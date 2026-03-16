# wajba_client — Flutter App Config Notes

## Android (android/app/src/main/AndroidManifest.xml)
Add these permissions inside <manifest>:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

Inside <application>:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

## android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        manifestPlaceholders = [GOOGLE_MAPS_API_KEY: "YOUR_KEY_HERE"]
    }
}
```

## iOS (ios/Runner/AppDelegate.swift)
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, ...)
  }
}
```

## iOS Info.plist — add:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>WAJBA a besoin de votre position pour trouver les restaurants proches</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>WAJBA utilise votre position pour le suivi de livraison</string>
```

## Environment setup (.env equivalent via app_constants.dart)
Change AppConstants.baseUrl to your backend IP/domain.
For local dev use: http://192.168.x.x:3000/api/v1

## Running
```bash
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Build AAB (Google Play)
```bash
flutter build appbundle --release
```
