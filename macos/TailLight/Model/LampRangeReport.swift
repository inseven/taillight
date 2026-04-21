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

import CoreHID

struct LampRangeReport {

    let autonomousMode: HIDElement
    let lampIdStart: HIDElement
    let lampIdEnd: HIDElement
    let redUpdateChannel: HIDElement
    let greenUpdateChannel: HIDElement
    let blueUpdateChannel: HIDElement
    let intensityUpdateChannel: HIDElement
    let lampUpdateFlags: HIDElement

    func update(settingAutonomousMode autonomousMode: Bool) -> HIDDeviceClient.ProvideElementUpdate {
        return HIDDeviceClient.ProvideElementUpdate(values: [
            self.autonomousMode.setter(newValue: autonomousMode ? 1 : 0),
        ])
    }

    func update(settingRed red: UInt8, green: UInt8, blue: UInt8, intensity: UInt8) -> HIDDeviceClient.ProvideElementUpdate {
        return HIDDeviceClient.ProvideElementUpdate(values: [

            // Specify the set of lamps we're acting on.
            lampIdStart.setter(newValue: 0),
            lampIdEnd.setter(newValue: 0),

            // Set the color and brightness.
            redUpdateChannel.setter(newValue: Int(red)),
            greenUpdateChannel.setter(newValue: Int(green)),
            blueUpdateChannel.setter(newValue: Int(blue)),
            intensityUpdateChannel.setter(newValue: Int(intensity)),

            // Commit the update.
            lampUpdateFlags.setter(newValue: 1),
        ])
    }

}
