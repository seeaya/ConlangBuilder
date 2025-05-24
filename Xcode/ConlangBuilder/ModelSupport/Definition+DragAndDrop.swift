// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
import SwiftData
import SwiftUI

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
