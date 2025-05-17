// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

@MainActor
protocol SidebarCoordinator {
    associatedtype Model: PersistentModel where Model.ID == PersistentIdentifier
    associatedtype RowContent: View
    associatedtype MenuContent: View

    func updateSelection(to newSelection: Set<PersistentIdentifier>)
    func view(forModel model: Model) -> RowContent
    func menu(forSelection selection: [Model]?) -> MenuContent
    func model(for persistentIdentifier: PersistentIdentifier) -> Model?
    func typeSelectString(forModel model: Model) -> String?
    func delete(models: [Model])

    var models: [Model] { get }
}
