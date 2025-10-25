Building and signing the Android APK / AAB

Quick steps to create a production-ready APK (or AAB) that points to your production admin proxy.

1) Set the production API base at build time

Use `--dart-define=API_BASE=https://your-proxy.example.com` so the app points to the deployed proxy.

Example build commands:

```powershell
# Release APK
flutter build apk --release --dart-define=API_BASE=https://admin-api.example.com

# Or build an Android App Bundle for Play Store
flutter build appbundle --release --dart-define=API_BASE=https://admin-api.example.com
```

2) Signing

Follow the standard Flutter docs for signing: generate a keystore with `keytool`, add `key.properties`, and configure `android/app/build.gradle` to use it.

3) Test and distribute

- Test the generated APK on a device.
- Upload the AAB to the Play Console for distribution.

If you want, I can:
- Add `--dart-define` usage to CI scripts.
- Add a helper `build_release.ps1` to automate the build and embedding of the API base.
