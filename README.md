# Unitify – All-in-One Converter

A production-oriented Android unit converter built with Flutter and Material 3. Unitify includes 14 categories, smart search, favorites, a 100-entry history, instant validation, configurable precision, and light/dark/system themes.

All calculations and application data remain on the device. The app includes no advertising, analytics, tracking, account system, or backend. Conversion works offline; a network connection is used only to check Google Play for a newer app version.

## Features

- Length, mass, temperature, area, volume, speed, time, data storage, pressure, energy, power, frequency, angle, and fuel consumption
- Accurate centralized conversion engine with absolute-zero and physical-value validation
- Correct decimal (SI) and binary data-storage units
- Correct reciprocal US and imperial fuel-economy formulas
- Search by category, unit name, or symbol
- Favorite unit pairs and debounced local conversion history
- Locally bundled Poppins typography; no runtime font download
- Responsive Material 3 interface with edge-to-edge Android layouts
- Persistent theme, decimal precision, and preferred category
- Google Play update prompts when a newer public version is available

## Requirements

- Flutter 3.32 or newer compatible stable release
- Dart 3.8 or newer
- Android SDK 36 for the current Play target requirement
- Java 17

## Run locally

```sh
flutter pub get
flutter run
```

Quality checks:

```sh
flutter analyze
flutter test
```

Build an Android App Bundle:

```sh
flutter build appbundle --release
```

## Project structure

```text
lib/
├── core/        # conversion catalog, themes, formatting
├── models/      # immutable units, categories, favorites, history
├── providers/   # persistent application state
├── screens/     # home, converter, favorites, history, settings
├── services/    # conversion engine and local storage
└── widgets/     # shared presentation components
```

## Android release signing

The repository never stores signing secrets. The release build reads `android/key.properties` and stops with an error when it is missing; it never falls back to a debug key.

1. Create an upload key and keep it outside the repository.
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Replace every placeholder with the actual key path and credentials.
4. Store the keystore and credentials in a secure password manager/CI secret store.
5. Run `flutter build appbundle --release` and verify the resulting AAB signature before uploading.

The Android application ID and Kotlin package are set to `com.therath.unitify`. Application IDs cannot be changed after publication.

## Play Store release checklist

- [x] Replace the placeholder Android application ID with a developer-owned, unique value (`com.therath.unitify`).
- [ ] Configure the upload keystore without committing `key.properties` or the keystore.
- [ ] Keep `targetSdk` at the current Play requirement. As of October 26, 2026, new apps and updates must target Android 16 / API 36 or higher.
- [ ] Run `flutter analyze`, `flutter test`, and a release AAB build.
- [ ] Test the signed bundle on small/large phones, dark mode, landscape, large text, and Android 16.
- [ ] Complete Play Console identity/developer verification and app-content declarations.
- [ ] Host [PRIVACY_POLICY.md](PRIVACY_POLICY.md) at a stable public HTTPS URL and replace its contact placeholder.
- [ ] Complete the Data safety form accurately (the current implementation collects and shares no data).
- [ ] Supply a 512×512 Play icon, 1024×500 feature graphic, phone screenshots, support email, and store category.
- [ ] Use the draft copy in [PLAY_STORE_LISTING.md](PLAY_STORE_LISTING.md), editing claims if the implementation changes.
- [ ] Use internal/closed testing and complete any testing requirement shown for the developer account before production access.
- [ ] Review pre-launch reports, accessibility checks, device compatibility, and policy status in Play Console.
- [ ] Confirm the latest target API and Play policies again immediately before submission.

This project is prepared for release workflows but does not claim Play policy approval; final compliance and console declarations remain the publisher's responsibility.

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md). The same concise policy is available in the app under Settings.
