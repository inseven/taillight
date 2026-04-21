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

    @State var selection: LightColor = .red

    var body: some View {

        Button("Request Permission...") {
            applicationModel.requestPermission()
        }

        Divider()

        Picker("Color", selection: $selection) {
            ForEach(LightColor.allCases) { lightColor in
                Text(lightColor.name)
            }
        }

        Divider()

        Button("About...", systemImage: "info.circle") {
            openURL(.about)
        }

        Menu("Settings", systemImage: "gear") {
            SettingsMenu()
        }

        Divider()

        Menu("Help") {

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
