"""Build optimized runtime sprites for Finny.

Source art stays in assets/images/finni/{stage,ears,pattern,mood}.
The app consumes mood_sprite and mood_portrait. Appearance source images
remain available for the offline expression compositor.

Development dependencies: pillow, numpy, opencv-python.
"""
from __future__ import annotations

from pathlib import Path

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FINNI = ROOT / "assets" / "images" / "finni"
STAGES = ("little", "growing", "confident")
COLORS = ("turquoise", "sand", "lavender")
EARS = ("pointed", "rounded", "floppy")
PATTERNS = ("natural", "spots", "stripes")
MOODS = ("quiet", "calm", "happy", "delighted")
RUNTIME_SIZE = 1024

def _open(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def _save_webp(image: Image.Image, path: Path, *, quality: int = 92) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if image.size != (RUNTIME_SIZE, RUNTIME_SIZE):
        image = image.resize((RUNTIME_SIZE, RUNTIME_SIZE), Image.Resampling.LANCZOS)
    image.save(path, "WEBP", quality=quality, method=2, exact=True)


def _appearance_source(stage: str, color: str, ears: str, pattern: str) -> Image.Image:
    base = _open(FINNI / "stage" / f"{stage}_{color}.png")
    ear = base if ears == "pointed" else _open(FINNI / "ears" / f"{stage}_{color}_{ears}.webp")
    patterned = base if pattern == "natural" else _open(FINNI / "pattern" / f"{stage}_{color}_{pattern}.webp")

    if ears == "pointed":
        return patterned
    if pattern == "natural":
        return ear

    # Pattern art supplies the body/tail; ear art supplies the head. A wide,
    # feathered overlap crosses the scarf rather than the face, so no visible
    # hard seam is left in the final exported sprite.
    width, height = base.size
    y = np.arange(height, dtype=np.float32) / height
    body_mask = np.clip((y - 0.53) / (0.64 - 0.53), 0.0, 1.0)
    head_mask = 1.0 - np.clip((y - 0.62) / (0.70 - 0.62), 0.0, 1.0)

    body = np.array(patterned, dtype=np.float32)
    head = np.array(ear, dtype=np.float32)
    body[:, :, 3] *= body_mask[:, None]
    head[:, :, 3] *= head_mask[:, None]

    result = Image.fromarray(np.clip(body, 0, 255).astype(np.uint8), "RGBA")
    result.alpha_composite(Image.fromarray(np.clip(head, 0, 255).astype(np.uint8), "RGBA"))
    return result


def build_appearances() -> None:
    out = FINNI / "appearance"
    for stage in STAGES:
        for color in COLORS:
            for ears in EARS:
                for pattern in PATTERNS:
                    image = _appearance_source(stage, color, ears, pattern)
                    _save_webp(image, out / f"{stage}_{color}_{ears}_{pattern}.webp")


def _turquoise_portrait(source: Image.Image) -> Image.Image:
    rgba = np.array(source.convert("RGBA"))
    hsv = cv2.cvtColor(rgba[:, :, :3], cv2.COLOR_RGB2HSV)
    hue, sat, val = cv2.split(hsv)
    purple = (hue >= 125) & (hue <= 170) & (sat > 55)
    hue[purple] = 90
    sat[purple] = np.clip(sat[purple].astype(np.float32) * 1.06, 0, 255).astype(np.uint8)
    rgb = cv2.cvtColor(cv2.merge([hue, sat, val]), cv2.COLOR_HSV2RGB)
    return Image.fromarray(np.dstack([rgb, rgba[:, :, 3]]).astype(np.uint8), "RGBA")


def _portrait(color: str, mood: str) -> Image.Image:
    source_color = "lavender" if color == "turquoise" else color
    image = _open(FINNI / "mood" / f"{source_color}_{mood}.webp")
    return _turquoise_portrait(image) if color == "turquoise" else image


def build_portraits() -> None:
    out = FINNI / "mood_portrait"
    for color in COLORS:
        for mood in MOODS:
            image = _portrait(color, mood)
            image.thumbnail((512, 512), Image.Resampling.LANCZOS)
            canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
            canvas.alpha_composite(image, ((512 - image.width) // 2, (512 - image.height) // 2))
            canvas.save(out / f"{color}_{mood}.webp", "WEBP", quality=92, method=2, exact=True)


def main() -> None:
    build_appearances()
    build_portraits()
    from build_finni_face_sprites import build as build_faces

    build_faces()
    print("Finny runtime assets built: 81 appearances, 324 mood sprites, 12 portraits.")


if __name__ == "__main__":
    main()
