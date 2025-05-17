// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

@Model
class Word {
    var conWord: String

    @Relationship(deleteRule: .cascade, inverse: \Definition.word)
    var definitions: [Definition]

    @Transient var orderedDefinitions: [Definition] {
        definitions.sorted { $0.index < $1.index }
    }

    init(conWord: String = "") {
        self.conWord = conWord
        self.definitions = []
    }
}

// MARK: - Actions
extension Word {
    func addNewDefinition() {
        definitions.append(Definition(index: definitions.count))
    }
}

// MARK: - Samples
@MainActor
extension Word {
    static let sample1 = Word(conWord: "Apple")
    static let sample2 = Word(conWord: "Banana")
    static let sample3 = Word(conWord: "Cherry")
    static let sample4 = Word(conWord: "Durian")
}
