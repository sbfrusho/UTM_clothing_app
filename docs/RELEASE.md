# Releasing to Google Play

This file is expanded in Sprint 11. Release signing is already in place.

## 1. Create an upload keystore (one time)
```sh
keytool -genkey -v -keystore ~/yourshop-upload.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```
Back this file and its passwords up somewhere safe, such as a password manager. If you lose them, you can't publish updates without asking Google to reset the key.

## 2. Create `android/key.properties` (git-ignored)
```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=/Users/<you>/yourshop-upload.jks
```
When this file exists, `android/app/build.gradle.kts` signs release builds with it. When it doesn't, release builds fall back to the debug key, which is fine for local testing only.

## 3. Build the app bundle
```sh
cp env/example.json env/prod.json   # set APP_ENV=prod and real publishable keys
flutter build appbundle --release --dart-define-from-file=env/prod.json
```
Output: `build/app/outputs/bundle/release/app-release.aab`.

## 4. Versioning
Bump `version:` in `pubspec.yaml` (`<versionName>+<versionCode>`) for every upload. The versionCode must always increase.
