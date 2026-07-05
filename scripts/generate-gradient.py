#!/usr/bin/env python3

# Copyright (c) 2026 Jason Morley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import argparse
import colorsys
import math
import os
import struct
import zlib

SCRIPTS_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
ROOT_DIRECTORY = os.path.dirname(SCRIPTS_DIRECTORY)
GRAPHICS_DIRECTORY = os.path.join(ROOT_DIRECTORY, "graphics")

VARIANTS = {
    "light": {
        "value": 0.95,
        "saturation_min": 0.25,
        "saturation_max": 1.0,
    },
    "dark": {
        "value": 0.45,
        "saturation_min": 0.35,
        "saturation_max": 1.0,
    },
}


def generate(width, height, value, saturation_min, saturation_max):
    center_x = (width - 1) / 2
    center_y = (height - 1) / 2
    max_radius = math.hypot(center_x, center_y)
    rows = []
    for j in range(height):
        dy = j - center_y
        row = bytearray()
        for i in range(width):
            dx = i - center_x
            radius = min(math.hypot(dx, dy) / max_radius, 1.0)
            hue = (math.atan2(dy, dx) / (2 * math.pi)) % 1.0
            saturation = saturation_min + (saturation_max - saturation_min) * radius
            r, g, b = colorsys.hsv_to_rgb(hue, saturation, value)
            row += bytes((int(round(r * 255)), int(round(g * 255)), int(round(b * 255))))
        rows.append(bytes(row))
    return rows


def write_png(path, width, height, rows):

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data +
                struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff))

    signature = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    raw = bytearray()
    for row in rows:
        raw += b"\x00" + row
    idat = zlib.compress(bytes(raw), 9)
    with open(path, "wb") as fh:
        fh.write(signature)
        fh.write(chunk(b"IHDR", ihdr))
        fh.write(chunk(b"IDAT", idat))
        fh.write(chunk(b"IEND", b""))


def main():
    parser = argparse.ArgumentParser(description="Generate the TailLight icon background gradient.")
    parser.add_argument("--width", type=int, required=True)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--variant", choices=sorted(VARIANTS.keys()), action="append", dest="variants")
    parser.add_argument("--output-directory", default=GRAPHICS_DIRECTORY)
    parser.add_argument("--output", help="exact output path; only valid with a single --variant")
    options = parser.parse_args()

    variants = options.variants or sorted(VARIANTS.keys())
    if options.output and len(variants) != 1:
        parser.error("--output can only be used with a single --variant")

    os.makedirs(options.output_directory, exist_ok=True)
    for variant in variants:
        settings = VARIANTS[variant]
        rows = generate(options.width, options.height, **settings)
        if options.output:
            path = options.output
        else:
            suffix = "" if variant == "light" else f"-{variant}"
            path = os.path.join(options.output_directory, f"icon-background{suffix}.png")
        write_png(path, options.width, options.height, rows)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
