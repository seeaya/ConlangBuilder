// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
import SwiftData
import SwiftUI

@main
@MainActor
struct ConlangBuilderApp: App {
    var body: some Scene {
        DocumentGroup(editing: .conlangDocument, migrationPlan: ConlangMigrationPlan.self) {
            ContentView()
                .environment(Conlang())
        } prepareDocument: { context in
            do {
                try context.validate()
                // Don't want to start with pending edits
                try context.save()
            } catch {
                // TODO: Handle gracefully
                fatalError("Failed to prepare document")
            }
        }
    }
}
