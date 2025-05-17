// Copyright (c) Connor Barnes. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

@Model
class Definition {
    var pronunciation: String
    var localWord: String
    var definitionDescription: String
    private(set) var index: Int

    @Relationship(deleteRule: .nullify)
    private(set) var word: Word?

    init(
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
extension Definition {
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
extension Definition {
    @MainActor static let sample1 = Definition(
        pronunciation: "Popcorn",
        localWord: "Blimp",
        definitionDescription: "A flying machine."
    )
}

// MARK: - Drag & Drop
struct DefinitionProxy: Codable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .definition)
    }

    let id: PersistentIdentifier

    init(for model: Definition) {
        id = model.id
    }

    func model(for context: ModelContext) -> Definition? {
        context.model(for: id) as? Definition
    }
}
