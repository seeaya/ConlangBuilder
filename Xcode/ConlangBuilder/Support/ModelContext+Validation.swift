// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData

extension ModelContext {
    /// Validates a model context by making sure that there is exactly `1` `Conlang` entity.
    ///
    /// If there are no `Conlang` entities (such as when creating a new document), a default one will be added to the context.
    ///
    /// If there are multiple `Conlang` entities, then all but the first will be deleted. It shouldn't be possible for there to be multiple `Conlang` entities, but this will  still fix such a situation.
    @MainActor
    func validate() throws {
        let conlangs = try fetch(FetchDescriptor<Conlang>())

        switch conlangs.count {
        case 0:
            insert(Conlang())
        case 1:
            break
        default:
            // TODO: Log
            conlangs.dropFirst().forEach { delete($0) }
        }
    }
}
