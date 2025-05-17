// Copyright (c) Connor Barnes. All rights reserved.

import SwiftUI

struct WindowFrame: NSViewRepresentable {
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        // Do nothing
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .titlebar
        view.blendingMode = .withinWindow
        return view
    }
}
