# Finny Stage 2 – Windows build note

This archive disables Kotlin incremental compilation because the project is on F: while the default Pub cache is normally on C:. On Windows, Kotlin may otherwise fail with `this and base files have different roots` while compiling Flutter plugins such as `shared_preferences_android`.

Run from the project root:

```powershell
flutter clean
flutter pub get
flutter run
```

For a permanent machine-level fix, move/set `PUB_CACHE` to a folder on F: and then you may remove `kotlin.incremental=false` from `android/gradle.properties`.
