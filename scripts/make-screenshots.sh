#!/bin/bash

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

set -e
set -o pipefail
set -u

ROOT_DIRECTORY="$( cd "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" &> /dev/null && pwd )"
SCRIPTS_DIRECTORY="$ROOT_DIRECTORY/scripts"
IMAGES_DIRECTORY="$ROOT_DIRECTORY/docs/images"

# Padding (in source pixels) added around the screenshot on every side before the gradient is drawn.
PADDING=80

WORKING_DIRECTORY="$(mktemp -d)"
trap 'rm -rf "$WORKING_DIRECTORY"' EXIT

function make_screenshot {
    local variant="$1"
    local input="$2"
    local output="$3"

    local width height
    width="$(sips -g pixelWidth "$input" | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$input" | awk '/pixelHeight/ { print $2 }')"

    local padded_width=$((width + PADDING * 2))
    local padded_height=$((height + PADDING * 2))

    local gradient="$WORKING_DIRECTORY/gradient-$variant.png"
    python3 "$SCRIPTS_DIRECTORY/generate-gradient.py" \
        --variant "$variant" \
        --width "$padded_width" \
        --height "$padded_height" \
        --output "$gradient"

    magick "$gradient" "$input" -gravity center -composite "$output"
}

make_screenshot light \
    "$IMAGES_DIRECTORY/screenshot-default@2x.png" \
    "$IMAGES_DIRECTORY/screenshot-default-social@2x.png"

make_screenshot dark \
    "$IMAGES_DIRECTORY/screenshot-default-dark@2x.png" \
    "$IMAGES_DIRECTORY/screenshot-default-dark-social@2x.png"
