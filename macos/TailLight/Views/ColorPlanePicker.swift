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

import SwiftUI

struct ColorPlanePicker: View {

    @Binding var color: HSBColor

    private struct LayoutMetrics {
        static let planeHeight: CGFloat = 140
        static let barHeight: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let knobSize: CGFloat = 14
        static let knobBorderWidth: CGFloat = 2
        static let knobShadowRadius: CGFloat = 1
    }

    var body: some View {
        VStack {
            saturationBrightnessPlane
            hueSlider
        }
    }

    private var saturationBrightnessPlane: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color(hue: color.hue, saturation: 1, brightness: 1))
                LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing)
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                knob(fill: color.color)
                    .position(x: color.saturation * size.width,
                              y: (1 - color.brightness) * size.height)
            }
            .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius).strokeBorder(.primary.opacity(0.1)))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        color.saturation = (value.location.x / size.width).clamped(min: 0, max: 1)
                        color.brightness = (1 - value.location.y / size.height).clamped(min: 0, max: 1)
                    }
            )
        }
        .frame(height: LayoutMetrics.planeHeight)
    }

    private var hueSlider: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                LinearGradient(colors: stride(from: 0.0, through: 1.0, by: 1.0 / 6.0)
                    .map { Color(hue: $0, saturation: 1, brightness: 1) },
                               startPoint: .leading,
                               endPoint: .trailing)
                knob(fill: Color(hue: color.hue, saturation: 1, brightness: 1))
                    .position(x: color.hue * width, y: LayoutMetrics.barHeight / 2)
            }
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(.primary.opacity(0.1)))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        color.hue = (value.location.x / width).clamped(min: 0, max: 1)
                    }
            )
        }
        .frame(height: LayoutMetrics.barHeight)
    }

    private func knob(fill: Color) -> some View {
        Circle()
            .fill(fill)
            .frame(width: LayoutMetrics.knobSize, height: LayoutMetrics.knobSize)
            .overlay(Circle().strokeBorder(.white, lineWidth: LayoutMetrics.knobBorderWidth))
            .shadow(radius: LayoutMetrics.knobShadowRadius)
    }

}
