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

extension HIDDeviceClient {

    // Look through the elements and pull out the collection of update elements corresponding with the first lamp
    // range report. The lamp range report is identified by the presnece of a lamp id start element.
    var lampRangeReport: LampRangeReport? {
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
        return LampRangeReport(autonomousMode: autonomousMode,
                               lampIdStart: lampIdStart,
                               lampIdEnd: lampIdEnd,
                               redUpdateChannel: redUpdateChannel,
                               greenUpdateChannel: greenUpdateChannel,
                               blueUpdateChannel: blueUpdateChannel,
                               intensityUpdateChannel: intensityUpdateChannel,
                               lampUpdateFlags: lampUpdateFlags)
    }

    func setColor(_ color: LampColor) async {
        guard let lampRangeReport = lampRangeReport else {
            return
        }
        do {
            let autonomousModeUpdate = await lampRangeReport.update(settingAutonomousMode: false)
            let colorUpdate = await lampRangeReport.update(settingRed: color.red, green: color.green, blue: color.blue, intensity: color.intensity)
            let results = await updateElements([autonomousModeUpdate, colorUpdate])
            try results[autonomousModeUpdate]?.get()
            try results[colorUpdate]?.get()
        } catch {
            print("Failed to update color with error \(error).")
        }
    }

}
