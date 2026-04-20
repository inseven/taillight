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
import CoreHID
import IOKit

import Sparkle

@Observable
class ApplicationModel {

    let updaterController = SPUStandardUpdaterController(startingUpdater: false,
                                                         updaterDelegate: nil,
                                                         userDriverDelegate: nil)

    let manager = HIDDeviceManager();

    init() {
        start()
    }

    func requestPermission() {
        let granted = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        print(granted)
    }

    func start() {

#if !DEBUG
        updaterController.startUpdater()
#endif

        Task {
            await scan()
        }
    }

    private func scan() async {
        do {
            let matchingCriteria = HIDDeviceManager.DeviceMatchingCriteria(primaryUsage: .genericDesktop(.mouse),
                                                                           deviceUsages: [.lightingAndIllumination(.lampArray)],
                                                                           vendorID: 0x045E,
                                                                           productID: 0x082A)
            for try await notification in await manager.monitorNotifications(matchingCriteria: [matchingCriteria]) {
                switch notification {
                case .deviceMatched(let deviceReference):

                    guard
                        let client = HIDDeviceClient(deviceReference: deviceReference),
                        let lampRangeReport = await client.lampRangeReport
                    else {
                        continue
                    }
                    let autonomousModeUpdate = lampRangeReport.update(settingAutonomousMode: false)
                    let colorUpdate = lampRangeReport.update(settingRed: 255, green: 0, blue: 0, intensity: 255)
                    let results = await client.updateElements([autonomousModeUpdate, colorUpdate])
                    try results[autonomousModeUpdate]?.get()
                    try results[colorUpdate]?.get()

                case .deviceRemoved(_):
                    continue

                default:
                    continue
                }
            }
        } catch {
            print("Failed with error \(error).");
        }
    }

    @MainActor func quit() {
        NSApplication.shared.terminate(nil)
    }

}
