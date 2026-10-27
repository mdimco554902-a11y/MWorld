# MWorld

**Mythril World** — an indestructible, high-altitude training crucible where mages and warriors can unleash powerful spells without wrecking the fragile mortal realm.

Inside MWorld, **Brawl Arena** is a 2D top-down brawler prototype with a cozy high-fantasy feel: forests, elves, mages, and arena trials.

## What you do in the game

- Start on the landing screen and choose **Play**, **Settings**, or **About**
- Pick your brawler avatar and give them a callsign
- Pick a map and set up a match
- Choose a loadout: **Sword**, **Bow**, or **Bomb**
- Choose bot difficulty: **Easy**, **Normal**, or **Hard**
- Fight in the arena until victory or defeat is decided

## Gameplay

- Top-down arena combat with a 60 FPS simulation
- Roblox-style avatars with visible bodies, hands, and animated stepping feet
- Simultaneous controls: on-screen virtual joystick and keyboard **WASD**
- Attack-blocking obstacles, such as ruined cars, barricades, crates, and walls
- Weapon-tailored stats, flying arrows, timed bomb detonations, and melee slash arcs
- Floating health bars and real-time victory/defeat tracking
- Landing-screen sections for the story, how to play, and expedition features

## Screens

| Route | Screen |
| --- | --- |
| `/` | Landing screen |
| `/avatar-select` | Avatar picker |
| `/map-select` | Map selection |
| `/match-setup` | Match setup |
| `/settings` | Settings, including audio and joystick options |
| `/about` | About MWorld |
| `/game` | Arena gameplay |

## Tech stack

- **Flutter** and **Dart** (SDK `^3.13.0`)
- **Provider** for state management, with `AppStateController` and `GameController`
- **MVC-style structure** under `lib/`
- **Google Fonts**, **Cupertino Icons**, and **SharedPreferences**
- Platforms in this repo: Android, iOS, Web, Windows, Linux, and macOS

## Project structure

```
lib/
  main.dart                  # BrawlArenaApp, providers, routes, themes
  controllers/
    app_state_controller.dart
    game_controller.dart
  core/
    theme.dart
  models/
  theme/
  utils/
  views/
    screens/
      about_screen.dart
      avatar_select_screen.dart
      game_screen.dart
      landing_screen.dart
      map_select_screen.dart
      match_setup_screen.dart
      settings_screen.dart
```

## Getting started

You need Flutter installed first. Then, from the project root:

```bash
flutter pub get
flutter run
```

Run on a specific target, for example:

```bash
flutter run -d chrome
flutter run -d windows
```

## Build

Android APK:

```bash
flutter build apk --release
```

Smaller, split APKs:

```bash
flutter build apk --split-per-abi --release
```

Windows:

```bash
flutter build windows --release
```

For Windows, copy the whole `Release` folder when sharing the game, not just the `.exe` on its own.

## Status

MWorld is in active development as a playable prototype. Gameplay, maps, avatars, and balance are still being tuned, so expect changes as new trials and features are added.
