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

import Diligence
import Glitter
import Sparkle

struct MainMenu: View {

    @Environment(ApplicationModel.self) var applicationModel

    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow

    private var lightMode: Binding<LightMode> {
        Binding {
            applicationModel.lightMode
        } set: { newValue in
            applicationModel.lightMode = newValue
            if case .custom = newValue {
                openWindow(id: ColorPickerWindow.id)
            }
        }
    }

    var body: some View {

        Divider()

        switch applicationModel.state {
        case .unknown:

            Button("Allow 'Input Monitoring'...", systemImage: "hand.raised") {
                applicationModel.requestPermission()
            }

        case .authorized:

            Menu("Color", systemImage: "swatchpalette") {
                Picker("Color", selection: lightMode) {
                    ForEach(NamedColor.allCases) { namedColor in
                        Text(namedColor.name)
                            .tag(LightMode.named(namedColor))
                    }
                    Divider()
                    Text("Custom...")
                        .tag(LightMode.custom(applicationModel.lightMode.hsbColor))
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

        case .denied:

            Button("Allow 'Input Monitoring'...", systemImage: "hand.raised") {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
                openURL(url)
            }

        }

        Divider()

        Button("About...", systemImage: "info.circle") {
            openURL(.about)
        }

        Menu("Settings", systemImage: "gear") {
            SettingsMenu()
        }

        Menu("Help", systemImage: "questionmark.circle") {

            Button("Website", systemImage: "globe") {
                openURL(URL(string: "https://taillight.jbmorley.co.uk")!)
            }

            Button("Privacy Policy", systemImage: "globe") {
                openURL(URL(string: "https://taillight.jbmorley.co.uk/privacy-policy")!)
            }

            Button("GitHub", systemImage: "globe") {
                openURL(URL(string: "https://github.com/inseven/taillight")!)
            }

            Button("Support", systemImage: "envelope") {
                let subject = "TailLight Support (\(Bundle.main.extendedVersion ?? "Unknown Version"))"
                openURL(URL(address: "support@jbmorley.co.uk", subject: subject)!)
            }

            Divider()

            Button("Donate", systemImage: "globe") {
                openURL(.donate)
            }

            Button {
                openURL(URL(string: "https://jbmorley.co.uk/software")!)
            } label: {
                Label("More Software by Jason Morley", systemImage: "globe")
            }

        }

        Divider()

        UpdateLink(updater: applicationModel.updaterController.updater)

        Divider()

        Button("Quit", systemImage: "xmark.rectangle") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")

    }

}
