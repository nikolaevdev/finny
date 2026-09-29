"""Check every packaged Finny emotion sprite and its source alignment."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from PIL import Image

from build_finni_face_sprites import (
    ALIGNMENT,
    COLORS,
    EARS,
    EMOTIONS,
    FINNI,
    PATTERNS,
    SOURCE,
    STAGES,
)

ROOT = Path(__file__).resolve().parents[1]


def validate() -> None:
    sprites = FINNI / "mood_sprite"
    manifest = json.loads((SOURCE / "manifest.json").read_text())
    alignment = json.loads(ALIGNMENT.read_text())
    expected = set()
    checked = 0

    for stage in STAGES:
        for color in COLORS:
            for ears in EARS:
                for pattern in PATTERNS:
                    stem = f"{stage}_{color}_{ears}_{pattern}"
                    dx, dy, confidence = alignment[stem]
                    assert confidence >= 0.9, (stem, confidence)
                    with Image.open(FINNI / "appearance" / f"{stem}.webp") as source:
                        base = np.asarray(source.convert("RGBA"))

                    for emotion in EMOTIONS:
                        filename = f"{stem}_{emotion}.webp"
                        expected.add(filename)
                        with Image.open(sprites / filename) as sprite:
                            image = np.asarray(sprite.convert("RGBA"))
                        assert image.shape == base.shape == (1024, 1024, 4), filename

                        original = emotion == ("calm" if stage == "confident" else "happy")
                        if original:
                            assert np.array_equal(image, base), filename
                        else:
                            left, top, right, bottom = manifest[
                                f"{stage}_{color}_{emotion}"
                            ]["bbox"]
                            left += dx
                            right += dx
                            top += dy
                            bottom += dy
                            assert 0 <= left < right <= 1024, filename
                            assert 0 <= top < bottom <= 1024, filename

                            # WEBP is lossy; outside the mouth rectangle its
                            # compression may change pixels slightly. Structural
                            # face features stay untouched in the compositor.
                            face_above_mouth = np.abs(
                                image[:top, :, :3].astype(np.int16)
                                - base[:top, :, :3].astype(np.int16)
                            )
                            assert np.percentile(face_above_mouth, 99) <= 12, filename
                            assert not np.array_equal(
                                image[top:bottom, left:right],
                                base[top:bottom, left:right],
                            ), filename

                        # Empty transparent pixels must not contain a visible
                        # opaque dark box where the mouth meets the neck.
                        assert np.count_nonzero(
                            (base[:, :, 3] == 0) & (image[:, :, 3] > 32)
                        ) == 0, filename
                        checked += 1

    actual = {p.name for p in sprites.iterdir() if p.is_file()}
    assert actual == expected, (sorted(actual - expected), sorted(expected - actual))
    pubspec = (ROOT / "pubspec.yaml").read_text()
    assert "- assets/images/finni/mood_sprite/" in pubspec
    assert "- assets/images/finni/expression/" not in pubspec
    character = (ROOT / "lib/core/widgets/finni_character.dart").read_text()
    assert "ShaderMask" not in character.split("class FinniCharacter extends")[1]
    assert "expression/" not in character
    assert checked == 324
    print(f"Validated {checked} sprites: all variants, alignment and bundle paths.")


if __name__ == "__main__":
    validate()
