# Launcher

A minimalist, gesture-driven Android home screen built with Flutter. Instead of a traditional icon grid, navigation is entirely swipe-based: the home screen is a hub and every direction leads to a purposeful window.

---

## Features

- **Gesture navigation** — swipe in any direction from the home screen to open a themed window
- **Thematic windows** — separate screens for Chat, Sport, and Quick-access apps, each showing only the apps you configure
- **Swipe shortcuts** — assign any app to a swipe gesture inside each window for instant launch
- **Clock** — full-screen clock with configurable tap and long-press app actions
- **Battery arc** — circular battery indicator with color-coded status and a configurable tap action
- **App list** — searchable full app drawer; long-press any app to open its Android settings
- **Persistent config** — all settings are saved to device storage and backed up via Android Auto Backup

---

## Navigation

```
              [ App List ]
                  ↑
[ Sport ] ← [ Home ] → [ Quick ]
                  ↓
              [ Chat ]
```

From the home screen:
| Gesture | Destination |
|---------|-------------|
| Swipe up | App list (full searchable drawer) |
| Swipe down | Chat window |
| Swipe right | Sport window |
| Swipe left | Quick window |

Inside each window, additional swipe gestures launch configured shortcut apps.

---

## Getting Started

**Prerequisites**: Flutter SDK ≥ 3.7.2, Android device or emulator

```bash
flutter pub get
flutter run                    # run on connected device
flutter build apk              # build release APK
flutter build apk --debug      # build debug APK
flutter analyze                # static analysis
flutter test                   # run tests
```

> This app is designed for Android only. The iOS, web, and desktop targets are present as Flutter scaffolding but are not actively maintained.

---

## Configuration

Open the configuration screen by tapping the **settings icon** (⚙) in the top-right corner of the App List screen.

### Clock
- **Tap** / **Hold** — assign an app to launch when the clock is tapped or long-pressed

### Battery
- **Tap** — assign an app to launch when the battery arc is tapped

### App Page Shortcuts
- Up to 4 swipe-direction shortcuts for the app list screen

### Windows (Chat / Sport / Quick)
- **Apps** — choose which installed apps appear in this window
- **Shortcuts** — assign swipe-direction shortcuts for quick launch within the window

All changes are saved by pressing the **save icon** (💾) in the top-right corner of the config screen.

---

## Architecture

```
lib/
├── main.dart                        # Entry point, root BlocProviders
├── app/
│   ├── route/                       # Named route definitions and router
│   └── theme/                       # App theme and shared color constants
├── features/
│   ├── app_list/                    # Installed apps fetching, caching, display
│   ├── battery/                     # Battery level monitoring and arc display
│   ├── clock/                       # Tick-based clock state and display
│   └── config/                      # App configuration (model, repository, cubit, UI)
└── pages/
    ├── home/                        # Home hub with clock + battery
    ├── app/                         # Full app drawer with search
    ├── chat/                        # Chat apps window
    ├── sport/                       # Sport apps window
    └── quick/                       # Quick-access apps window
```

**State management**: `flutter_bloc` with Cubits only. Two root-level Cubits (`AppListCubit`, `ConfigCubit`) are provided at the app root. `ClockCubit` and `BatteryCubit` are scoped to the home screen.

**Persistence**: `ConfigRepository` serializes `AppConfig` to JSON in `SharedPreferences`. Android Auto Backup syncs this data to the user's Google account.

**App list caching**: `AppListCubit` uses a static in-memory cache with a 30-minute TTL. The cache is loaded immediately on each launch; background refreshes replace the list silently without blocking the UI.

---

## Tech Stack

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | Cubit-based state management |
| `equatable` | Value equality for state classes |
| `installed_apps` | Enumerate, launch, and open settings for installed apps |
| `battery_plus` | Battery level and charging state |
| `shared_preferences` | Persistent JSON config storage |

**Font**: [Hermit](https://pcaro.es/hermit/) — a monospaced font bundled under `assets/fonts/`.

---

## License

MIT
