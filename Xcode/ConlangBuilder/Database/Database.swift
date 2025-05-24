// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

@MainActor
struct Database {
    @ModelActor
    actor Background {
        static nonisolated func create(container: ModelContainer) async -> Background {
            Background(modelContainer: container)
        }
    }

    let mainContext: ModelContext

    var background: Background {
        get async { await task.value }
    }

    private let task: Task<Background, Never>

    init(container: ModelContainer) {
        self.mainContext = container.mainContext
        self.task = Task { await Background.create(container: container) }
    }
}
