// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
import SwiftData
import SwiftUI

struct SidebarPreview: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Word.conWord)
    private var words: [Word]

    @State private var selection: Set<PersistentIdentifier> = []

    private let useNative: Bool

    init(useNative: Bool) {
        self.useNative = useNative
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                if useNative {
                    List(words, selection: $selection) { word in
                        Text(word.conWord)
                    }
                    .contextMenu(forSelectionType: PersistentIdentifier.self) { wordIDs in
                        let words = wordIDs.compactMap { modelContext.model(for: $0) as? Word }

                        menuContent(selection: words)
                    }
                } else {
                    Sidebar(words, selection: $selection) { word in
                        Text(word.conWord)
                    } menu: { selection in
                        menuContent(selection: selection)
                    } typeSelectString: { word in
                        word.conWord
                    }
                }

                Divider()

                bottomBar
            }
        } detail: {
            Text("Detail")
        }
    }
}

private extension SidebarPreview {
    @ViewBuilder var addButton: some View {
        Button {
            let model = Word(conWord: "\(Int.random(in: 1..<100))")
            modelContext.insert(model)
            try? modelContext.save()
        } label: {
            Image(systemName: "plus")
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }

    @ViewBuilder var removeButton: some View {
        Button {
            let models = selection.compactMap { modelContext.model(for: $0) }
            models.forEach { modelContext.delete($0) }
            try? modelContext.save()
        } label: {
            Image(systemName: "minus")
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }

    @ViewBuilder var randomizeButton: some View {
        Button {
            let models = selection.compactMap { modelContext.model(for: $0) }
            models.forEach { model in
                if let word = model as? Word {
                    word.conWord = "\(Int.random(in: 1..<100))"
                }
            }
        } label: {
            Image(systemName: "dice.fill")
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }

    @ViewBuilder var bottomBar: some View {
        HStack {
            addButton
            removeButton
            randomizeButton
            selectMenu
        }
        // swiftlint:disable:next no_magic_numbers
        .frame(height: 20)
        // swiftlint:disable:next no_magic_numbers
        .padding(4)
        .buttonStyle(.plain)
    }

    @ViewBuilder var selectMenu: some View {
        Menu {
            Button("All") {
                selection = Set(words.map(\.id))
            }

            Button("None") {
                selection = []
            }
        } label: {
            Image(systemName: "checklist")
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
    }

    @ViewBuilder
    func menuContent(selection: [Word]?) -> some View {
        if let selection {
            ForEach(selection) { word in
                Text(word.conWord)
            }
        } else {
            Text("<table>")
        }
    }
}

// MARK: - Previews

#Preview {
    PreviewWrapper {
        SidebarPreview(useNative: false)
    }
}

#Preview {
    PreviewWrapper {
        SidebarPreview(useNative: true)
    }
}
