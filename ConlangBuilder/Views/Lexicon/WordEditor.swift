// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

@MainActor
struct WordEditor {
    @Bindable private var word: Word

    @Environment(\.modelContext)
    private var modelContext

    init(word: Word) {
        self.word = word
    }
}

// MARK: - View
extension WordEditor: View {
    var body: some View {
        VStack(spacing: 0) {
            header
            definitionsList
        }
    }
}

// MARK: - Subviews
private extension WordEditor {
    var header: some View {
        VStack {
            TextField(text: $word.conWord, prompt: Text("Conword")) {
                EmptyView()
            }
            .font(.title)
            .textFieldStyle(.plain)
            .onChange(of: word.conWord) {
                // Needed to cause sidebar to refresh contents
                try? modelContext.save()
            }

            Divider()
        }
        .padding([.horizontal, .top])
    }

    var definitionsList: some View {
        List {
            ForEach(word.orderedDefinitions) { definition in
                DefinitionEditor(definition: definition)
            }
            .dropDestination(action: insert(definitions:at:))
        }
        .listRowSeparator(.visible)
        .scrollContentBackground(.hidden)
        .listRowInsets(EdgeInsets())
        .overlay {
            if word.definitions.isEmpty {
                VStack {
                    Text("No definitions")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Helpers
private extension WordEditor {
    func insert(definitions: [DefinitionProxy], at index: Int) {
        let definitions = definitions.compactMap { $0.model(for: modelContext) }

        guard definitions.count == 1 else {
            // TODO: Handle gracefully
            fatalError("Multiple definition drops at once are unsupported")
        }

        withAnimation(.snappy) {
            definitions.forEach { definition in
                if definition.word == word {
                    // Reorder
                    guard definition.index < word.orderedDefinitions.count else { return }
                    word.orderedDefinitions[definition.index].move(toIndex: index)
                } else {
                    // Moving from another word
                    // TODO: Support this
                    fatalError("Definition drops from another word are unsupported")
                }
            }
        }
    }

    func addNewDefinition() {
        withAnimation(.snappy) {
            word.addNewDefinition()
        }
    }
}

// MARK: - Previews
#Preview {
    PreviewWrapper {
        WordEditor(word: .sample1)
    }
}
