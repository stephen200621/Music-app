# VYBE 3D — Personal AI Music Player

> An Android-first, offline-intelligent personal music player featuring 3D perspective motion, SQLite persistence, background media notifications, and multi-signal local recommendation scoring.

---

## 🎧 Architecture & Highlights

- **100% On-Device & Private**: Zero mandatory registration, zero cloud analytics, zero external API keys required. All listening history and preferences remain securely on your phone.
- **Audio Playback Engine**: Powered by `just_audio` + `audio_service` + `audio_session`, delivering background playback, lock-screen controls, Bluetooth media buttons, and audio-focus ducking/interruption handling.
- **3D Motion Visual Identity**:
  - **Interactive 3D Music Orb**: Layered radial shaders, orbital harmonic rings, ambient glow, and micro-particles with tactile spring transitions.
  - **Floating 3D Album Art**: Real perspective tilt responding to touch/drag via `Matrix4.identity()..setEntry(3, 2, 0.0015)..rotateX(..)..rotateY(..)`.
  - **Rotating Vinyl Disc**: Continuous rotation during playback, seamless pause-resume angle caching, and procedural grooved sound rings.
  - **Audio Visualizer**: Responsive frequency spectrum visualizer bars with smooth idle fallback.
- **Multi-Signal AI Recommendation Engine**:
  - Dynamically weights **Mode Biases** (Chill, Focus, Workout, Sleep, Party, Custom), **Play Count**, **Full Completion Rates**, **Skip Penalties** (-5.0 for tracks skipped in under 20s), and a **Recency Penalty** to eliminate monotonous repetition.
  - Generates transparent, human-readable rationale badges explaining *why* every song was selected.
- **Full Offline Persistence (SQLite)**: 9 relational tables with indexes (`songs`, `playlists`, `playlist_songs`, `liked_songs`, `play_history`, `listening_preferences`, `app_settings`, `playback_session`, `playback_queue`).
- **Session Auto-Restoration**: Automatically saves and restores track position, queue order, and mode settings when the app is reopened.

---

## 📱 Complete Screen Suite

1. **Home**: Time-appropriate personalized greeting, 3D Music Orb, search bar, "Continue Listening" card, quick mood cards, "Made For You" AI shelf, library shelf, and persistent Mini-Player.
2. **Now Playing**: Floating 3D album cover with interactive touch tilt, optional vinyl disc slide-out, transport controls, interactive slider, favorite button, visualizer, and mode badge.
3. **Discover (AI Recommendations)**: Ranked cards with match percentages, algorithmic rationale badges ("Tailored for Chill vibe (85% energy match)", "Because you frequently enjoy..."), like/dismiss buttons, and on-device privacy guarantee.
4. **Playback Queue**: Reorderable drag-and-drop list, track deletion, clear queue with confirmation, save queue as a playlist.
5. **Listening History**: Timeline grouped by Today, Yesterday, and Earlier date headers, tracking completion percentages and skip events, with JSON export and replay actions.
6. **Music Library**: Tabs for All Songs, Liked, Playlists, Albums, Artists, and Genres; search, sort by title/artist/album/recently added, and device MediaStore rescan.
7. **Music Modes**: 6 dedicated modes (Chill, Focus, Workout, Sleep, Party, Custom) with energy bias meters and sleep fadeout timer.
8. **Equalizer & Audio Settings**: 3-band frequency shaping (Bass, Mid, Treble), audio effect presets (Flat, Bass Boost, Vocal, Acoustic, Electronic), sleep timer, and honest DSP communication.
9. **Settings**: Library rescan, Android permission status, Reduced Motion toggle, session auto-resume toggle, JSON history backup, and local privacy statement.

---

## 🚀 Getting Started & Build Instructions

### Prerequisites
- Flutter SDK (>=3.10.0)
- Android SDK (API 21 to 34+)
- Java JDK 17

### 1. Setup Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run Locally on Android Device / Emulator
```bash
flutter run
```

### 4. Build Android Debug APK
```bash
flutter build apk --debug
```
The output APK will be generated at:
`build/app/outputs/flutter-apk/app-debug.apk`

---

## 🛡️ Android Permissions Configured
- `android.permission.WAKE_LOCK`: Ensures continuous playback when the screen locks.
- `android.permission.FOREGROUND_SERVICE`: Runs the media playback service in the background.
- `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Required for Android 14+ (API 34).
- `android.permission.POST_NOTIFICATIONS`: Android 13+ media notification controls.
- `android.permission.READ_MEDIA_AUDIO`: Android 13+ local audio file access.
- `android.permission.READ_EXTERNAL_STORAGE`: Backward compatibility for Android 12 and below.

---

## 📄 License
MIT License. Built for private, personal use.
