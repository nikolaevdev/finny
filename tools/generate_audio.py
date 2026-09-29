"""Generate the original Finny UI sound effects.

Background music is bundled separately as optimized OGG resources.
This script regenerates only the four UI effects and never changes music files.
"""
from array import array
from math import pi, sin, tanh
from pathlib import Path
import wave

RATE = 22050
DEST = Path(__file__).resolve().parents[1] / 'android/app/src/main/res/raw'
DEST.mkdir(parents=True, exist_ok=True)


def note(samples, start, duration, frequency, volume=.1, kind='bell'):
    offset = int(start * RATE)
    count = min(int(duration * RATE), len(samples) - offset)
    for i in range(max(count, 0)):
        t = i / RATE
        fade_in = min(1.0, t * 85)
        if kind == 'bell':
            envelope = fade_in * (1 - t / duration) ** 2.4
            voice = sin(2*pi*frequency*t) + .24*sin(4*pi*frequency*t) + .08*sin(6*pi*frequency*t)
        else:
            envelope = fade_in * max(0.0, 1 - t / duration) ** 1.4
            voice = sin(2*pi*frequency*t)
        samples[offset + i] += voice * envelope * volume


def write_wav(path, samples, gain=.8):
    peak = max(max(samples), -min(samples), .01)
    pcm = array('h', (int(max(-1, min(1, tanh(value * gain / peak * 1.4))) * 32760) for value in samples))
    with wave.open(str(path), 'wb') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(pcm.tobytes())


def effect(name, tones, length):
    samples = array('f', [0.0]) * int(length * RATE)
    for start, duration, hz, amp in tones:
        note(samples, start, duration, hz, amp)
    write_wav(DEST / f'finni_{name}.wav', samples, .52)


def main():
    effect('tap', [(0, .075, 650, .7)], .09)
    effect('success', [(0, .37, 523.25, .5), (.10, .34, 659.25, .5), (.19, .38, 783.99, .55)], .60)
    effect('warning', [(0, .22, 392, .5), (.15, .24, 349.23, .45)], .42)
    effect('purchase', [(0, .18, 659.25, .45), (.10, .26, 880, .48)], .40)
    print('Finny UI sound effects generated. Bundled music files were not changed.')


if __name__ == '__main__':
    main()
