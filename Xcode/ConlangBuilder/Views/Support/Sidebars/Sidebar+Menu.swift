// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

extension Sidebar {
    struct Menu: View {
        private let selectionProvider: SelectionProvider
        private let content: ([Model]) -> MenuContent?

        init(selectionProvider: SelectionProvider, content: @escaping ([Model]) -> MenuContent?) {
            self.selectionProvider = selectionProvider
            self.content = content
        }

        var body: some View {
            content(selectionProvider.selection)
        }
    }
}

extension Sidebar {
    @Observable
    final class SelectionProvider {
        var selection: [Model] = []
    }
}
