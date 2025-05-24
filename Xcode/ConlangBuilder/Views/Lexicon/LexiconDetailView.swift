// Copyright (c) Connor Barnes. All rights reserved.

import Combine
import ConlangModels
import SwiftData
import SwiftUI

@MainActor
struct LexiconDetailView {
    @Environment(\.modelContext)
    private var modelContext

    @State private var wordCount = 0

    @State private var wordCountCancellable: AnyCancellable?

    private let selectedWords: [Word]

    init(selectedWords: [Word]) {
        self.selectedWords = selectedWords
    }
}

// MARK: - View
extension LexiconDetailView: View {
    var body: some View {
        VStack(spacing: 0) {
            content
            Spacer()
            bottomBar
        }
    }
}

// MARK: - Subviews
private extension LexiconDetailView {
    @ViewBuilder var content: some View {
        switch (selectedWords.count, selectedWords.first) {
        case (1, .some(let word)):
            WordEditor(word: word)
        case (0, _):
            Spacer()

            Text("No Selection")
                .foregroundStyle(.secondary)
                .font(.title2)
        default:
            Spacer()

            Text("Multiple Selection")
                .foregroundStyle(.secondary)
                .font(.title2)
        }
    }

    @ViewBuilder var bottomBar: some View {
        BottomBar {
            ZStack {
                HStack {
                    addDefinitionButton
                    Spacer()
                }

                Text(bottomBarTextTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .animation(nil, value: selectedWords.first?.definitions.count)
            }
        }
        .onAppear {
            wordCountCancellable = NotificationCenter.default.publisher(
                for: ModelContext.didSave,
            )
            .receive(on: RunLoop.main)
            .sink { _ in
                fetchWordCount()
            }

            fetchWordCount()
        }
    }

    var addDefinitionButton: some View {
        Button(action: addNewDefinition) {
            Image(systemName: "plus")
        }
        .disabled(selectedWords.count != 1)
    }
}

// MARK: - Actions
private extension LexiconDetailView {
    func addNewDefinition() {
        guard
            selectedWords.count == 1,
            let word = selectedWords.first
        else { return }

        withAnimation(.snappy) {
            word.addNewDefinition()
        }
    }
}

// MARK: - Helpers
private extension LexiconDetailView {
    var bottomBarTextTitle: LocalizedStringKey {
        switch (selectedWords.count, selectedWords.first) {
        case (1, .some(let word)):
            "\(selectedWords.count) of \(wordCount) words selected, \(word.definitions.count) definitions"
        case (0, _):
            "\(wordCount) words"
        default:
            "\(selectedWords.count) of \(wordCount) words selected"
        }
    }

    func fetchWordCount() {
        try? wordCount = modelContext.fetchCount(FetchDescriptor<Word>())
    }
}

// MARK: - Previews
#Preview {
    PreviewWrapper {
        LexiconDetailView(selectedWords: [Word(conWord: "Word")])
    }
}
