// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
import SwiftData
import SwiftUI

@MainActor
struct ContentView {
    @State private var tabSelection = TopLevelTab.lexicon

    @State private var selectedWordIDs: Set<PersistentIdentifier> = []

    @State private var selectedPartOfSpeechIDs: Set<PersistentIdentifier> = []

    @State private var path = NavigationPath()

    @Environment(\.modelContext)
    private var modelContext
}

extension ContentView: View {
    var body: some View {
        NavigationSplitView {
            sidebar(forTab: tabSelection)
        } detail: {
            detail(forTab: tabSelection)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Tab", selection: $tabSelection) {
                    ForEach(TopLevelTab.allCases) { tab in
                        Image(systemName: tab.imageName)
                            .help(tab.localizedTitle)
                            .accessibilityLabel(Text(tab.localizedTitle))
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// MARK: - Subviews
private extension ContentView {
    @ViewBuilder
    func detail(forTab tab: TopLevelTab) -> some View {
        switch tab {
        case.lexicon:
            LexiconDetailView(selectedWords: selectedWords)
        case .partsOfSpeech:
            Text("Parts of Speech")
        }
    }

    @ViewBuilder
    func sidebar(forTab tab: TopLevelTab) -> some View {
        switch tab {
        case .lexicon:
            ModelSelectionSidebar(
                for: Word.self,
                title: \.conWord,
                selectedModelIDs: $selectedWordIDs,
                newModel: Word()
            )
        case .partsOfSpeech:
            ModelSelectionSidebar(
                for: PartOfSpeech.self,
                title: \.conName,
                selectedModelIDs: $selectedPartOfSpeechIDs,
                newModel: PartOfSpeech()
            )
        }
    }
}

// MARK: - Helpers
private extension ContentView {
    var selectedWords: [Word] {
        selectedWordIDs.compactMap { modelContext.model(for: $0) as? Word }
    }

    var selectedPartsOfSpeech: [PartOfSpeech] {
        selectedPartOfSpeechIDs.compactMap { modelContext.model(for: $0) as? PartOfSpeech }
    }
}

// MARK: - TopLevelTab
enum TopLevelTab: CaseIterable, Identifiable {
    case lexicon
    case partsOfSpeech

    var id: Self { self }

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .lexicon:
            "Lexicon"
        case .partsOfSpeech:
            "Parts of Speech"
        }
    }

    var imageName: String {
        switch self {
        case .lexicon:
            "book"
        case .partsOfSpeech:
            "puzzlepiece"
        }
    }
}

#Preview {
    PreviewWrapper {
        ContentView()
    }
}
