# Sonique Mobile

A Flutter-based music app featuring authentication, browsing, likes, albums, playlists, and in-app audio playback.

## Overview

Sonique Mobile is the Flutter client for the Sonique platform. It uses a Clean Architecture approach with BLoC for state management, GoRouter for navigation, and audioplayers for playback. Configuration is managed via a `.env` file bundled as an asset.

- Platform: Android, iOS (Flutter)
- Language: Dart
- Architecture: Clean Architecture (Data / Domain / Presentation)
- State management: flutter_bloc
- Routing: go_router
- DI/Service Locator: get_it
- Media: audioplayers
- Caching and storage: cached_network_image, shared_preferences

## Features

- User authentication and session management
- Browse and fetch songs, artists, and albums
- Like/unlike songs and view liked songs
- Create and manage playlists; add/remove songs
- Album CRUD operations (create, add/remove songs)
- Audio playback with basic controls
- Responsive dark theme
- Environment-based configuration

## Tech Stack

- Flutter/Dart (Dart SDK ^3.7.2)
- flutter_bloc, go_router, get_it
- audioplayers, cached_network_image
- http, http_parser, shared_preferences
- image_picker, permission_handler, file_picker
- flutter_dotenv

## Project Structure

The app follows a layered, feature-oriented structure:

```
lib/
  core/
    services/locator/         # get_it setup
    theme/                     # App theme
  Data/
    services/                  # Network/services (e.g., SongService)
    source/                    # Data sources (e.g., AuthLocalDataSource)
  Domain/
    repository/                # Repository abstractions
    usecases/                  # Use case classes (business logic)
  Representation/
    Bloc/                      # BLoC feature folders (auth, songs, albums, artists, playlists, player)
  main.dart                    # App entry: DI, MultiBlocProvider, GoRouter
```

Key initialization (see `lib/main.dart`):
- Loads environment from `.env`
- Sets up service locator (get_it)
- Registers MultiBlocProvider for Auth, Songs, User Data, Player, Likes, Albums, Playlists
- Configures `MaterialApp.router` with GoRouter

## Getting Started

### Prerequisites

- Flutter SDK installed
- Xcode (for iOS) / Android Studio (for Android)
- A running backend API compatible with Sonique (example: be-sonique)
  - Optional reference: be-sonique (https://github.com/AungKyawPhyo1142/be-sonique)

### 1) Clone and install dependencies

```bash
git clone https://github.com/Nyi-NyiSoe/sonique-mobile.git
cd sonique-mobile
flutter pub get
```

### 2) Configure environment

Create a `.env` file in the project root. The app expects `.env` to be bundled as an asset (see `pubspec.yaml`).

Example `.env` (placeholders — update to your backend):

```
API_BASE_URL=https://your-api.example.com
# Add any other keys your services expect, e.g.
# AUTH_CLIENT_ID=...
# AUTH_CLIENT_SECRET=...
```

Note:
- `.env` is listed under `flutter/assets` in `pubspec.yaml`, so it will be available at runtime.

### 3) Run the app

```bash
# Run on a connected device or emulator
flutter run
```

## Platform Notes

- iOS:
  - After first run, if you use CocoaPods, you may need: `cd ios && pod install && cd ..`
  - Ensure required Info.plist keys for permissions used by image_picker/permission_handler (e.g., camera, photo library, microphone if applicable).
- Android:
  - Ensure required permissions in `AndroidManifest.xml` for storage/media access if features need them.
- Audio:
  - For background or advanced playback behaviors, you may need additional platform setup.

## Permissions

Depending on the features you use, configure:
- Android: `AndroidManifest.xml`
- iOS: `Info.plist`
Packages that may require permissions: `image_picker`, `permission_handler`, media/file access for uploads or selections.

Consult package docs for the exact keys and configuration.

## Scripts and Commands

- Get packages: `flutter pub get`
- Analyze: `flutter analyze`
- Format: `dart format .`
- Run: `flutter run`
- Build (Android): `flutter build apk`
- Build (iOS): `flutter build ios`

## Troubleshooting

- Missing .env: Ensure `.env` exists at project root and is listed as an asset in `pubspec.yaml`.
- Dependency issues: Run `flutter clean && flutter pub get`.
- iOS pods: Run `cd ios && pod repo update && pod install`.
- API errors: Verify `API_BASE_URL` and backend availability.

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit changes: `git commit -m "feat: add your feature"`
4. Push to branch: `git push origin feat/your-feature`
5. Open a Pull Request

## License

This project’s license is not specified. If you intend to open source it, consider adding a LICENSE file (e.g., MIT, Apache-2.0).

## Acknowledgements

- Flutter team and ecosystem
- flutter_bloc, go_router, get_it, audioplayers communities
