"""Static release checks that do not require Flutter or Android SDK."""
from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
FINNI = ROOT / "assets" / "images" / "finni"
RAW = ROOT / "android" / "app" / "src" / "main" / "res" / "raw"

STAGES = ("little", "growing", "confident")
COLORS = ("turquoise", "sand", "lavender")
EARS = ("pointed", "rounded", "floppy")
PATTERNS = ("natural", "spots", "stripes")
MOODS = ("quiet", "calm", "happy", "delighted")

errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def check_files(folder: Path, expected: set[str], label: str) -> None:
    actual = {p.name for p in folder.glob("*") if p.is_file()}
    missing = sorted(expected - actual)
    extra = sorted(actual - expected)
    require(not missing, f"{label}: missing {missing}")
    require(not extra, f"{label}: unexpected {extra}")
    for name in expected & actual:
        require((folder / name).stat().st_size > 0, f"{label}: empty file {name}")
    print(f"{label}: {len(actual)} files")


appearance = {
    f"{stage}_{color}_{ears}_{pattern}.webp"
    for stage in STAGES
    for color in COLORS
    for ears in EARS
    for pattern in PATTERNS
}
sprites = {
    f"{stage}_{color}_{ears}_{pattern}_{mood}.webp"
    for stage in STAGES
    for color in COLORS
    for ears in EARS
    for pattern in PATTERNS
    for mood in MOODS
}
portraits = {
    f"{color}_{mood}.webp"
    for color in COLORS
    for mood in MOODS
}

check_files(FINNI / "appearance", appearance, "Finny appearances")
check_files(FINNI / "mood_sprite", sprites, "Finny mood sprites")
check_files(FINNI / "mood_portrait", portraits, "Mood portraits")

for name in ("finni_tap.wav", "finni_success.wav", "finni_warning.wav", "finni_purchase.wav"):
    path = RAW / name
    require(path.is_file() and path.stat().st_size > 0, f"Missing UI sound: {name}")
print("UI sounds: 4 required files")

expected_music = {
    "finni_music_01_shop.ogg",
    "finni_music_02_calm.ogg",
    "finni_music_03_main.ogg",
}
music = {
    p.name for p in RAW.iterdir()
    if p.is_file() and re.fullmatch(r"finni_music_[a-z0-9_]+\.(ogg|mp3|wav|m4a)", p.name)
}
require(music == expected_music, f"Unexpected music resources: {sorted(music)}")
for name in expected_music:
    require((RAW / name).stat().st_size > 1_000_000, f"Music file looks incomplete: {name}")
print(f"Music tracks: {len(music)} ({', '.join(sorted(music))})")

pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
for asset_dir in (
    "assets/images/finni/mood_sprite/",
    "assets/images/finni/mood_portrait/",
):
    require(asset_dir in pubspec, f"pubspec.yaml does not bundle {asset_dir}")
require("version: 0.14.7+44" in pubspec, "Unexpected project version in pubspec.yaml")


# Story/background art is intentionally WebP and prewarmed before the router
# becomes visible. This reduces first-use I/O/decode spikes on Android.
story_assets = {
    ROOT / "assets/images/home/explorer_room_story.webp": 500_000,
    ROOT / "assets/images/shop/shop_counter_story.webp": 300_000,
    ROOT / "assets/images/goals/dream_cottage_story.webp": 300_000,
}
for path, max_bytes in story_assets.items():
    require(path.is_file(), f"Missing optimized story asset: {path.relative_to(ROOT)}")
    if path.is_file():
        require(path.stat().st_size <= max_bytes, f"Story asset is unexpectedly large: {path.relative_to(ROOT)}")

for legacy in (
    ROOT / "assets/images/home/explorer_room_story.png",
    ROOT / "assets/images/shop/shop_counter_story.png",
    ROOT / "assets/images/goals/dream_cottage_story.png",
):
    require(not legacy.exists(), f"Legacy PNG would be bundled too: {legacy.relative_to(ROOT)}")

app = (ROOT / "lib/app/app.dart").read_text(encoding="utf-8")
for story_name in (
    "explorer_room_story.webp",
    "shop_counter_story.webp",
    "dream_cottage_story.webp",
):
    require(story_name in app, f"Startup story prewarm is missing {story_name}")
require("precacheImage" in app and "_storyAssetsReady" in app, "Startup image warmup gate is missing")

main_activity = (ROOT / "android/app/src/main/kotlin/ru/mishanikolaev/finny/MainActivity.kt").read_text(encoding="utf-8")
for resource in (
    "R.raw.finni_music_01_shop",
    "R.raw.finni_music_02_calm",
    "R.raw.finni_music_03_main",
):
    require(resource in main_activity, f"Music scene resource is not wired: {resource}")
require('isLooping = true' in main_activity, "Scene music is not configured to loop")
require('"setMusicScene"' in main_activity, "Native music scene switching is missing")

router = (ROOT / "lib/app/router.dart").read_text(encoding="utf-8")
for scene in ("MusicScene.main", "MusicScene.calm", "MusicScene.shop"):
    require(scene in router, f"Route music mapping is missing {scene}")
require("observers: [_MusicRouteObserver()]" in router, "Music route observer is not registered")

character = (ROOT / "lib/core/widgets/finni_character.dart").read_text(encoding="utf-8")
require("ShaderMask(" not in character and "_expressionAlignment" not in character, "Finni still applies a runtime face overlay")
require("/mood_sprite/" in character and "moodSpriteAsset(" in character, "FinniCharacter does not use completed mood sprites")
require("class FinniCharacter extends StatefulWidget" in character, "FinniCharacter animation state is missing")
require("AnimatedContainer(" in character and "_motionTransform" in character, "Finni idle motion is missing")
require("tapReaction" in character and "_reactToTap" in character, "Finni tap reaction is missing")
require("disableAnimations" in character, "Finni animation does not respect reduce-motion accessibility")

home = (ROOT / "lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
require("animate: true" in home and "tapReaction: true" in home, "Home Finny animation is not wired")

onboarding = (ROOT / "lib/features/onboarding/presentation/onboarding_screen.dart").read_text(encoding="utf-8")
require("animate: true" in onboarding, "Onboarding Finny animation is not wired")

pet_creation = (ROOT / "lib/features/pet/presentation/pet_creation_screen.dart").read_text(encoding="utf-8")
require("animate: true" in pet_creation, "Pet creator Finny animation is not wired")

budget = (ROOT / "lib/features/budget/presentation/budget_screen.dart").read_text(encoding="utf-8")
require("animate: true" in budget, "Budget Finny animation is not wired")

motion = (ROOT / "lib/core/widgets/finni_pressable.dart").read_text(encoding="utf-8")
require("class FinniPressable extends StatefulWidget" in motion, "Button motion wrapper is missing")
require("AnimatedScale(" in motion and "Transform.translate" in motion, "Button press bounce is missing")
require("disableAnimations" in motion and "FinniMotionTheme" in motion, "Button motion does not respect animation accessibility/settings")

theme = (ROOT / "lib/app/theme/app_theme.dart").read_text(encoding="utf-8")
require("InkSparkle.splashFactory" in theme, "Game-like Material splash is missing")
require("FinniMotionTheme(enabled: animationsEnabled)" in theme, "App animation setting is not wired to button motion")

finni_button = (ROOT / "lib/core/widgets/finni_button.dart").read_text(encoding="utf-8")
require("FinniPressable(" in finni_button and "FinniPressEffect.reward" in finni_button, "Primary FinniButton motion is missing")

home_motion = (ROOT / "lib/features/home/presentation/home_screen.dart").read_text(encoding="utf-8")
require(home_motion.count("FinniPressable(") >= 5, "Home game actions are not wired to press motion")

shop_motion = (ROOT / "lib/features/shop/presentation/shop_screen.dart").read_text(encoding="utf-8")
require("FinniPressEffect.reward" in shop_motion, "Shop purchase button motion is missing")

if errors:
    print("\nFAILED")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("\nStatic release validation passed.")
