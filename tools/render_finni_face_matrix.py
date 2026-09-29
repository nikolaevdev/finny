"""Render the same precomposed sprites that FinniCharacter selects in Flutter."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SPRITES = ROOT / "assets/images/finni/mood_sprite"
ARTIFACTS = ROOT / "artifacts"
STAGES = ("little", "growing", "confident")
COLORS = ("turquoise", "sand", "lavender")
EARS = ("pointed", "rounded", "floppy")
PATTERNS = ("natural", "spots", "stripes")
EMOTIONS = ("quiet", "calm", "happy", "delighted")
FACE_BOUNDS = {
    "little": (290, 240, 960, 690),
    "growing": (330, 260, 960, 690),
    "confident": (290, 200, 930, 630),
}


def sprite(stage: str, color: str, ears: str, pattern: str, emotion: str) -> Image.Image:
    name = f"{stage}_{color}_{ears}_{pattern}_{emotion}.webp"
    return Image.open(SPRITES / name).convert("RGBA")


def sheet(stage: str, *, faces_only: bool = False) -> None:
    width, height = (240, 190) if faces_only else (190, 215)
    result = Image.new("RGB", (width * 12, height * 9), "#f4f0e9")
    draw = ImageDraw.Draw(result)
    combinations = (
        (color, ears, pattern, emotion)
        for color in COLORS
        for ears in EARS
        for pattern in PATTERNS
        for emotion in EMOTIONS
    )
    for index, (color, ears, pattern, emotion) in enumerate(combinations):
        image = sprite(stage, color, ears, pattern, emotion)
        if faces_only:
            image = image.crop(FACE_BOUNDS[stage])
        image.thumbnail((width - 8, height - 24), Image.Resampling.LANCZOS)
        tile = Image.new("RGBA", image.size, "white")
        tile.alpha_composite(image)
        x, y = index % 12 * width, index // 12 * height
        result.paste(tile.convert("RGB"), (x + (width - image.width) // 2, y + 22))
        draw.text((x + 4, y + 3), f"{color[:3]} {ears[:3]} {pattern[:3]} {emotion}", fill="black")
    suffix = "_faces" if faces_only else ""
    result.save(ARTIFACTS / f"finni_faces_{stage}_108{suffix}.png", compress_level=0)


def overview() -> None:
    width, height = 250, 290
    result = Image.new("RGB", (width * 12, height * 3), "#f4f0e9")
    draw = ImageDraw.Draw(result)
    for index, (stage, color, emotion) in enumerate(
        (s, c, e) for s in STAGES for c in COLORS for e in EMOTIONS
    ):
        image = sprite(stage, color, "pointed", "natural", emotion)
        image.thumbnail((width - 10, height - 26), Image.Resampling.LANCZOS)
        tile = Image.new("RGBA", image.size, "white")
        tile.alpha_composite(image)
        x, y = index % 12 * width, index // 12 * height
        result.paste(tile.convert("RGB"), (x + 5, y + 24))
        draw.text((x + 5, y + 4), f"{stage}/{color}/{emotion}", fill="black")
    result.save(ARTIFACTS / "finni_faces_36.png", compress_level=0)


if __name__ == "__main__":
    ARTIFACTS.mkdir(exist_ok=True)
    overview()
    for name in STAGES:
        sheet(name)
        sheet(name, faces_only=True)
    print(f"Contact sheets written to {ARTIFACTS}")
