# Required Local Assets

Some assets are intentionally excluded from GitHub because they are large, private, licensed, or generated.

## Excluded Asset Types

- TFLite model files
- GGUF/local LLM model files
- MP3/WAV/M4A music files
- Android release signing keys
- `.env` files and private service credentials
- Generated APKs, app bundles, screenshots, and recordings

## Local Placement

Place required model files locally in:

```text
assets/models/
```

Place optional music files locally in:

```text
assets/audio/
```

The Sakhi local model is downloaded or stored through the app document storage flow and should not be bundled into the APK.

## Why These Files Are Excluded

- Keeps the repository small and reviewable.
- Prevents accidental publication of licensed or private files.
- Avoids shipping signing keys or secrets.
- Keeps production builds explicit and reproducible.

The placeholder `.gitkeep` files keep the expected directories visible without committing the real assets.
