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

struct Device {

    let client: HIDDeviceClient

    private let autonomousMode: HIDElement
    private let lampIdStart: HIDElement
    private let lampIdEnd: HIDElement
    private let redUpdateChannel: HIDElement
    private let greenUpdateChannel: HIDElement
    private let blueUpdateChannel: HIDElement
    private let intensityUpdateChannel: HIDElement
    private let lampUpdateFlags: HIDElement

    init?(client: HIDDeviceClient) async {

        // Look through the elements and pull out the collection of update elements corresponding with the first lamp
        // range report. The lamp range report is identified by the presnece of a lamp id start element.
        let elements = await client.elements
        guard let autonomousMode = elements.first(where: { $0.usage == .lightingAndIllumination(.autonomousMode) }),
              let lampIdStart = elements.first(where: { $0.usage == .lightingAndIllumination(.lampIdStart) }),
              let lampIdEnd = elements.first(where: { $0.usage == .lightingAndIllumination(.lampIdStart) && $0.reportID == lampIdStart.reportID }),
              let redUpdateChannel = elements.first(where: { $0.usage == .lightingAndIllumination(.redUpdateChannel) && $0.reportID == lampIdStart.reportID }),
              let greenUpdateChannel = elements.first(where: { $0.usage == .lightingAndIllumination(.greenUpdateChannel) && $0.reportID == lampIdStart.reportID }),
              let blueUpdateChannel = elements.first(where: { $0.usage == .lightingAndIllumination(.blueUpdateChannel) && $0.reportID == lampIdStart.reportID }),
              let intensityUpdateChannel = elements.first(where: { $0.usage == .lightingAndIllumination(.intensityUpdateChannel) && $0.reportID == lampIdStart.reportID }),
              let lampUpdateFlags = elements.first(where: { $0.usage == .lightingAndIllumination(.lampUpdateFlags) && $0.reportID == lampIdStart.reportID })
        else {
            return nil
        }

        self.client = client
        self.autonomousMode = autonomousMode
        self.lampIdStart = lampIdStart
        self.lampIdEnd = lampIdEnd
        self.redUpdateChannel = redUpdateChannel
        self.greenUpdateChannel = greenUpdateChannel
        self.blueUpdateChannel = blueUpdateChannel
        self.intensityUpdateChannel = intensityUpdateChannel
        self.lampUpdateFlags = lampUpdateFlags
    }

    func setColor(_ lampColor: LampColor) async {
        let autonomousModeUpdate = update(settingAutonomousMode: false)
        let colorUpdate = update(settingRed: lampColor.red,
                                 green: lampColor.green,
                                 blue: lampColor.blue,
                                 intensity: lampColor.intensity)
        _ = await client.updateElements([autonomousModeUpdate, colorUpdate])
    }

    private func update(settingAutonomousMode autonomousMode: Bool) -> HIDDeviceClient.ProvideElementUpdate {
        return HIDDeviceClient.ProvideElementUpdate(values: [
            self.autonomousMode.setter(newValue: autonomousMode ? 1 : 0),
        ])
    }

    private func update(settingRed red: UInt8, green: UInt8, blue: UInt8, intensity: UInt8) -> HIDDeviceClient.ProvideElementUpdate {
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
