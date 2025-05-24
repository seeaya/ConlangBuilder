// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

@MainActor
struct ModelValidationView<Content: View> {
    @Query private var conlangs: [Conlang]

    @State private var conlang: Conlang?

    @Environment(\.modelContext)
    private var modelContext

    private let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
}

extension ModelValidationView: View {
    var body: some View {
        Group {
            if let conlang {
                content
                    .environment(conlang)
            } else {
                Color.clear
            }
        }
        .onChange(of: conlangs.count, initial: true) { _, count in
            conlang = conlangs.first
            guard count != 1 else { return }

            do {
                try modelContext.validate()
            } catch {
                // TODO: Log
                conlang = nil
            }
        }
    }
}

// MARK: - Previews
#Preview {
    ModelValidationView {
        Text("Content")
            .padding()
    }
    .modelContainer(.preview)
}
