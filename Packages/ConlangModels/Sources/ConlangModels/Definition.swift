// Copyright (c) Connor Barnes. All rights reserved.

import Foundation
import SwiftData
import SwiftUI // Needed for MutableCollection.move(fromOffsets:destination:)

@Model
public class Definition {
    public var pronunciation: String
    public var localWord: String
    public var definitionDescription: String
    public private(set) var index: Int

    @Relationship(deleteRule: .nullify)
    public private(set) var word: Word?

    public init(
        pronunciation: String = "",
        localWord: String = "",
        definitionDescription: String = "",
        index: Int = -1
    ) {
        self.pronunciation = pronunciation
        self.localWord = localWord
        self.definitionDescription = definitionDescription
        self.index = index
    }
}

// MARK: - Actions
public extension Definition {
    func delete() {
        guard let word else { return }
        let index = self.index
        word.definitions.removeAll { $0.id == id }
        word.definitions.filter { $0.index > index }
            .forEach { $0.index -= 1 }
    }

    func move(toIndex newIndex: Int) {
        guard let word else { return }
        var orderedDefinitions = word.orderedDefinitions
        orderedDefinitions.move(fromOffsets: IndexSet(integer: index), toOffset: newIndex)
        orderedDefinitions.enumerated().forEach { index, definition in
            definition.index = index
        }
    }
}

// MARK: - Samples
public extension Definition {
    @MainActor static let sample1 = Definition(
        pronunciation: "Popcorn",
        localWord: "Blimp",
        definitionDescription: "A flying machine."
    )
}
