// Copyright (c) 2026 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import AppKit
import SwiftUI

nonisolated struct HSBColor: Codable, Equatable, Hashable {

    var hue: Double
    var saturation: Double
    var brightness: Double

    init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
    }

    init(_ lampColor: LampColor) {
        let color = NSColor(srgbRed: CGFloat(lampColor.red) / 255,
                            green: CGFloat(lampColor.green) / 255,
                            blue: CGFloat(lampColor.blue) / 255,
                            alpha: 1)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        self.init(hue: Double(hue), saturation: Double(saturation), brightness: Double(brightness))
    }

}

extension HSBColor {

    static let black = HSBColor(hue: 0, saturation: 0, brightness: 0)

    var color: Color {
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    var lampColor: LampColor {
        let color = NSColor(hue: CGFloat(hue),
                            saturation: CGFloat(saturation),
                            brightness: CGFloat(brightness),
                            alpha: 1).usingColorSpace(.sRGB) ?? .black
        return LampColor(red: UInt8((color.redComponent * 255).rounded()),
                         green: UInt8((color.greenComponent * 255).rounded()),
                         blue: UInt8((color.blueComponent * 255).rounded()),
                         intensity: 255)
    }

}
