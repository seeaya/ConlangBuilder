// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

@Model
public final class Word {
    public var conWord: String

    @Relationship(deleteRule: .cascade, inverse: \Definition.word)
    public var definitions: [Definition]

    @Transient public var orderedDefinitions: [Definition] {
        definitions.sorted { $0.index < $1.index }
    }

    public init(conWord: String = "") {
        self.conWord = conWord
        self.definitions = []
    }
}

// MARK: - Actions
public extension Word {
    func addNewDefinition() {
        definitions.append(Definition(index: definitions.count))
    }
}

// MARK: - Samples
@MainActor
public extension Word {
    static let sample1 = Word(conWord: "Apple")
    static let sample2 = Word(conWord: "Banana")
    static let sample3 = Word(conWord: "Cherry")
    static let sample4 = Word(conWord: "Durian")
}
