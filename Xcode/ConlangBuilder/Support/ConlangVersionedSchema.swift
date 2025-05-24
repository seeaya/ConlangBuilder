// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
@preconcurrency import SwiftData

struct ConlangVersionedSchema: VersionedSchema {
    static let models: [any PersistentModel.Type] = [
        Conlang.self,
        Word.self,
        Definition.self,
        PartOfSpeech.self
    ]

    static let versionIdentifier = Schema.Version(0, 0, 1)
}

struct ConlangMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [ConlangVersionedSchema.self]
    static var stages: [MigrationStage] {
        []
    }
}
