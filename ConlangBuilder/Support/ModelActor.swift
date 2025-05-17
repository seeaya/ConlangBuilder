// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

extension ModelActor {
    func withContext<T, Failure: Error>(
        _ block: @Sendable (isolated Self, ModelContext) async throws(Failure) -> sending T
    ) async throws(Failure) -> sending T {
        try await block(self, modelContext)
    }
}

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
