// Copyright (c) Connor Barnes. All rights reserved.

import SwiftUI

struct BottomBar<Content: View> {
    private let content: Content
    private let backgroundHidden: Bool

    init(backgroundHidden: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.backgroundHidden = backgroundHidden
    }
}

// MARK: - View
extension BottomBar: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                content
            }
            .frame(height: Appearance.contentHeight)
            .padding(.horizontal, Appearance.horizontalContentInset)
            .buttonStyle(.plain)
        }
        .background {
            if !backgroundHidden {
                WindowFrame()
            }
        }
    }
}

// MARK: - Appearance
private enum BottomBarAppearance {
    static let contentHeight = 26.0
    static let horizontalContentInset = 8.0
}

private typealias Appearance = BottomBarAppearance

// MARK: - Preview
#Preview {
    BottomBar {
        Text("Hello")
    }
    .padding()
}
