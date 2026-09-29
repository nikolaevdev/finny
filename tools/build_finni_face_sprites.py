"""Build complete Finny sprites with an expression baked into each appearance.

Requires Pillow. The 18 checked mouth edits in tools/finni_face_sources are
aligned to each stage/color's pointed/natural source. face_alignment.json holds
the measured displacement of the nose for all ear and coat variants.
"""

from __future__ import annotations

import json
import os
import shutil
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
FINNI = ROOT / "assets/images/finni"
SOURCE = ROOT / "tools/finni_face_sources"
ALIGNMENT = SOURCE / "face_alignment.json"
STAGES = ("little", "growing", "confident")
COLORS = ("turquoise", "sand", "lavender")
EARS = ("pointed", "rounded", "floppy")
PATTERNS = ("natural", "spots", "stripes")
EMOTIONS = ("quiet", "calm", "happy", "delighted")


def build() -> None:
    face_sources = json.loads((SOURCE / "manifest.json").read_text())
    alignment = json.loads(ALIGNMENT.read_text())
    destination = FINNI / "mood_sprite"
    destination.mkdir(parents=True, exist_ok=True)
    for temporary in destination.glob("*.tmp.webp"):
        temporary.unlink()
    expected: set[str] = set()

    for stage in STAGES:
        for color in COLORS:
            for ears in EARS:
                for pattern in PATTERNS:
                    stem = f"{stage}_{color}_{ears}_{pattern}"
                    appearance_path = FINNI / "appearance" / f"{stem}.webp"
                    if not appearance_path.is_file():
                        raise FileNotFoundError(appearance_path)
                    displacement = alignment[stem]
                    dx, dy, confidence = displacement
                    if confidence < 0.9 or abs(dx) > 40 or abs(dy) > 40:
                        raise ValueError(f"Unreliable face alignment: {stem} {displacement}")

                    for emotion in EMOTIONS:
                        name = f"{stem}_{emotion}.webp"
                        expected.add(name)
                        path = destination / name
                        # The original source art is already the happy pose in
                        # the first two stages and the calm pose in the last.
                        original_emotion = (
                            emotion == "happy" if stage != "confident"
                            else emotion == "calm"
                        )
                        if original_emotion:
                            temporary = path.with_name(path.stem + ".tmp.webp")
                            shutil.copyfile(appearance_path, temporary)
                            os.replace(temporary, path)
                            continue

                        key = f"{stage}_{color}_{emotion}"
                        source = face_sources[key]
                        x, y, right, bottom = source["bbox"]
                        with Image.open(appearance_path) as image:
                            sprite = image.convert("RGBA")
                        with Image.open(SOURCE / f"{key}.png") as image:
                            patch = image.convert("RGBA")
                        if sprite.size != (1024, 1024):
                            raise ValueError(f"Unexpected canvas: {appearance_path}")
                        if patch.size != (right - x, bottom - y):
                            raise ValueError(f"Unexpected patch size: {key}")

                        # This happens once during the offline build. Flutter
                        # receives one completed image and applies no face mask.
                        target_area = sprite.crop(
                            (x + dx, y + dy, right + dx, bottom + dy)
                        )
                        patch.putalpha(ImageChops.multiply(
                            patch.getchannel("A"), target_area.getchannel("A")
                        ))
                        sprite.alpha_composite(patch, (x + dx, y + dy))
                        temporary = path.with_name(path.stem + ".tmp.webp")
                        sprite.save(temporary, "WEBP", quality=94, method=2, exact=True)
                        # Some Pillow/libwebp combinations can return without
                        # an exception after writing an empty file. Verify each
                        # output before proceeding to the next combination.
                        try:
                            with Image.open(temporary) as check:
                                check.load()
                                if check.size != sprite.size:
                                    raise ValueError(f"Wrong output canvas: {path}")
                        except (OSError, ValueError):
                            sprite.save(temporary, "WEBP", lossless=True, method=2, exact=True)
                            with Image.open(temporary) as check:
                                check.load()
                                if check.size != sprite.size:
                                    raise ValueError(f"Unreadable output: {temporary}")
                        os.replace(temporary, path)

    for temporary in destination.glob("*.tmp.webp"):
        temporary.unlink()
    unexpected = {p.name for p in destination.glob("*.webp")} - expected
    if unexpected:
        raise ValueError(f"Unexpected old mood sprites: {sorted(unexpected)}")
    for name in expected:
        path = destination / name
        with Image.open(path) as image:
            image.load()
            if image.size != (1024, 1024):
                raise ValueError(f"Unreadable sprite: {path}")
    print(f"Built {len(expected)} mood sprites in {destination}")


if __name__ == "__main__":
    build()
