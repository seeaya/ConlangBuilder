// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

struct PreviewWrapper<Content: View> {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension PreviewWrapper: View {
    var body: some View {
        ModelValidationView {
            content
        }
        .modelContainer(.preview)
    }
}

// MARK: Previews
#Preview {
    PreviewWrapper {
        Text("Preview")
            .padding()
    }
}
