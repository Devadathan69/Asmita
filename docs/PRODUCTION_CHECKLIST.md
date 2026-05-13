# Production Checklist

Use this checklist before preparing a public APK or Play Store app bundle.

## Build Mode

- Verify `APP_MODE=public`.
- Confirm restricted ASHA pilot surfaces are hidden or access-controlled.
- Confirm referral letter generation is disabled for public builds unless approved.
- Confirm clinical risk wording is not shown in public builds.

## Privacy And Security

- No temporary cloud AI routing remains.
- No API keys or private secrets exist in source control.
- Screenshot and screen-recording protection is enabled.
- No generated APKs, recordings, screenshots, models, or music files are staged.
- Android signing keys are stored outside the repository.
- Health data remains local and encrypted where required.
- Private chat content is not printed to logs.
- ASHA screening photos are deleted after processing.

## Verification

- `flutter clean`
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build appbundle --release --dart-define=APP_MODE=public`

## Store Readiness

- Privacy policy is ready.
- Google Play Data Safety form is accurate.
- Health Apps declaration is ready if applicable.
- AI content disclosure and feedback/reporting flow are ready if Sakhi is enabled.
- Release signing is configured outside Git.
- App has been tested on a physical Android device.

## Safety Wording

- No diagnostic claims.
- No disease confirmation wording.
- Wellness checks are described as screening or self-awareness.
- Sakhi and pregnancy support route urgent concerns to a trusted adult, ASHA worker, PHC, doctor, or local emergency help.
