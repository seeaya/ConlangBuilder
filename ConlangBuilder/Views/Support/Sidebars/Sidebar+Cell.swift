// Copyright (c) Connor Barnes. All rights reserved.

import SwiftUI

extension Sidebar {
    struct Cell: View {
        private let model: Model
        private let rowContent: (Model) -> RowContent

        init(model: Model, rowContent: @escaping (Model) -> RowContent) {
            self.model = model
            self.rowContent = rowContent
        }

        var body: some View {
            rowContent(model)
                .frame(height: SidebarAppearance.rowHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
