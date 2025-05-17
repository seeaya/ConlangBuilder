// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

extension ModelContainer {
    @MainActor static let preview: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: Conlang.self,
                Word.self,
                Definition.self,
                PartOfSpeech.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            container.setupForPreview()
            return container
        } catch {
            fatalError("Failed to create model container for preview")
        }
    }()
}

// MARK: - Helpers
private extension ModelContainer {
    @MainActor
    func setupForPreview() {
        mainContext.insert(Conlang())

        let words: [Word] = [.sample1, .sample2, .sample3, .sample4]
        words.forEach { mainContext.insert($0) }

        mainContext.insert(Definition.sample1)

        try? mainContext.save()
    }
}
