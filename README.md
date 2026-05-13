# Asmita

Privacy-first wellness companion for cycle tracking, pregnancy support, and non-diagnostic metabolic/hormonal wellness checks.

![Flutter](https://img.shields.io/badge/Flutter-Android-blue)
![Offline First](https://img.shields.io/badge/Offline--first-local%20storage-green)
![Privacy First](https://img.shields.io/badge/Privacy--first-encrypted%20data-purple)
![Prototype](https://img.shields.io/badge/Status-Hackathon%20prototype-orange)

Asmita is a Flutter-based wellness app built for adolescent girls and community health contexts in India. It supports private cycle tracking, daily logs, pregnancy support for adult users, Sakhi offline AI companion, napkin finder, phase-aware music, discreet mode, and optional restricted wellness or ASHA pilot workflows depending on the build flag.

## Medical Disclaimer

Asmita is not a diagnostic tool. It does not diagnose PCOS or any medical condition. Any wellness check output is for self-awareness and should be discussed with a qualified doctor, ASHA worker, or trusted health professional.

If symptoms feel severe, urgent, unsafe, or unusual, seek help from a trusted adult, ASHA worker, PHC, doctor, or local emergency medical service.

## Key Features

- Personal cycle tracking with private local history
- Pregnancy mode for users aged 18 and above
- Daily log for mood, energy, symptoms, notes, and pain map
- Sakhi offline AI companion with local chat memory
- Napkin finder with local fallback store data
- Phase-aware music player
- Discreet/privacy mode
- Local encrypted storage for sensitive data
- Optional Wellness Check / ASHA pilot mode depending on build flag

## App Modes

Asmita supports build-time modes through `APP_MODE`:

- `public`: Personal tracking first. Shows public-safe wellness features and hides restricted ASHA pilot surfaces.
- `hackathon`: Enables prototype and presentation flows for judging or internal demos.
- `asha_pilot`: Enables restricted ASHA pilot workflows intended for supervised field testing.

Public builds should avoid clinical tier wording, referral letter generation, and unrestricted ASHA Worker branding unless access is controlled.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- go_router for navigation
- SQLite / sqflite for local persistence
- AES-256-GCM local encryption
- TFLite for optional on-device vision models
- GGUF / local LLM runtime for Sakhi when enabled
- Android-first deployment

## Privacy-First Architecture

- No required login for core personal tracking
- Local-first storage
- Screenshot and screen-recording protection for production
- No ASHA screening photos stored permanently after processing
- No hardcoded API keys
- No analytics by default
- Local encrypted Sakhi memory and chat history
- Local fallback behavior where possible

## Folder Structure

```text
lib/
  config/
  db/
  providers/
  screens/
  services/
  theme/
  widgets/
assets/
  models/        # ignored, add locally
  audio/         # ignored, add locally
android/
docs/
```

## Setup

Install Flutter, clone the repository, then fetch dependencies:

```bash
flutter pub get
```

Run a public-mode local build:

```bash
flutter run --dart-define=APP_MODE=public
```

Run a hackathon prototype build:

```bash
flutter run --dart-define=APP_MODE=hackathon
```

## Build Commands

Public Play Store build:

```bash
flutter build appbundle --release --dart-define=APP_MODE=public
```

Hackathon APK:

```bash
flutter build apk --debug --dart-define=APP_MODE=hackathon
```

ASHA pilot app bundle:

```bash
flutter build appbundle --release --dart-define=APP_MODE=asha_pilot
```

## Required Local Assets

These files are intentionally not included in the repository:

- TFLite wellness/vision model files
- GGUF Sakhi local model files
- Audio MP3/WAV/M4A files
- Android signing keys
- `.env` files and private secrets

Use placeholder directories:

```text
assets/models/
assets/audio/
```

Model and audio assets should be added locally before development builds that require them. Do not commit model binaries, music files, generated APKs, or signing material.

## Sakhi Offline AI

Sakhi is intended to run through an offline/local model path. The model is downloaded or placed locally and stored outside the APK. Chat history and helpful memory stay on the device.

If the offline model is missing, the app should guide the user to download it. If inference fails, Sakhi shows a short friendly error instead of hanging.

## Safety and Responsible Use

Asmita is designed for supportive wellness tracking, not medical diagnosis. It uses calm, non-shaming language and encourages professional support when a user is worried. Pregnancy support is available only for adult users and gives general tracking guidance, not medical decisions.

Emergency or warning-sign guidance should always point users toward trusted adults, ASHA workers, PHCs, doctors, or local emergency support.

## Play Store Preparation Checklist

- Prepare and publish a privacy policy
- Complete Google Play Data Safety answers accurately
- Complete Health Apps declaration if applicable
- Add AI content disclosure and feedback/reporting flow if Sakhi is enabled
- Configure release signing outside the repository
- Build an app bundle with `APP_MODE=public`
- Test on low-end and mid-range Android devices
- Verify no private assets, keys, or generated builds are committed

## Team

Team Naayattu

- Devadathan M R
- Christina Paul
- MACE Kothamangalam
- WitchHunt 2026

## Status

Prototype / active development.

## License

License not yet selected.
