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

import Interact
import Sparkle

@MainActor
@Observable
class ApplicationModel {

    enum SettingsKey: String {
        case color
    }

    enum State {
        case unknown
        case authorized
        case denied
    }

    public var state: State = .unknown

    let updaterController = SPUStandardUpdaterController(startingUpdater: false,
                                                         updaterDelegate: nil,
                                                         userDriverDelegate: nil)

    var color: NamedColor {
        didSet {
            keyedDefaults.set(color.rawValue, forKey: .color)
            let lampColor = color.lampColor
            for client in clients {
                Task { await client.setColor(lampColor) }
            }
        }
    }

    private let manager = HIDDeviceManager();
    private let keyedDefaults = KeyedDefaults<SettingsKey>()
    private var clients: [HIDDeviceClient] = []


    init() {
        color = NamedColor(rawValue: keyedDefaults.string(forKey: .color, default: NamedColor.red.rawValue)) ?? .red
        start()
    }

    func requestPermission() {
        let granted = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        print(granted)
    }

    func start() {

        // Check to see if we're authorized.
        let access = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
        switch access {
        case kIOHIDAccessTypeDenied:
            state = .denied
        case kIOHIDAccessTypeGranted:
            state = .authorized
        case kIOHIDAccessTypeUnknown:
            state = .unknown
        default:
            state = .unknown
        }

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
                        await client.lampRangeReport != nil
                    else {
                        continue
                    }
                    clients.append(client)
                    let lampColor = color.lampColor
                    await client.setColor(lampColor)
                case .deviceRemoved(let deviceReference):
                    // Reasons Apple sucks #12948:
                    // We get the `HIDDeviceClient` instances we're about to remove and then capture them in a detatched
                    // Task to coax their destructors to be called outside of our current concurrency context. This is a
                    // workaround for what looks like a bug in the Swift HID wrappers that results in some kind of
                    // deadlock-related executor pool exhaustion that, after some iterations (connect/disconnect the
                    // mouse a number of times), would cause a hang in a `HIDDeviceClient.dinit`. Since all documentation
                    // I can find points `deinit` being nonisolated in Swift 5 and 6, a hang in `HIDDeviceClient.deinit`
                    // must be a result of some kind of leaked concurrency from that implementation---either a dispatch
                    // to `DispatchQueue.main` or, perhaps some nuanced shared synchronization mechanism between
                    // `HIDDeviceManager` and `HIDDeviceClient`. I note that if the bug was a simple deadlock resulting
                    // from a blocking `DispatchQueue.main` dispatch in `HIDDeviceClient.deinit`, then I'd expect to see
                    // the code lock up on the first disconnection, whereas we're seeing it do so after a period of
                    // time leaving me at somewhat of a loss as to the true mechanism.
                    let removedClients = clients.filter { $0.deviceReference == deviceReference }
                    clients.removeAll { $0.deviceReference == deviceReference }
                    Task.detached { _ = removedClients }
                default:
                    continue
                }
            }
        } catch {
            print("Failed to scan for devices with error \(error).");
        }
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

}
