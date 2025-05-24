// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

extension ModelActor {
    func withContext<T, Failure: Error>(
        _ block: @Sendable (isolated Self, ModelContext) async throws(Failure) -> sending T
    ) async throws(Failure) -> sending T {
        try await block(self, modelContext)
    }
}
