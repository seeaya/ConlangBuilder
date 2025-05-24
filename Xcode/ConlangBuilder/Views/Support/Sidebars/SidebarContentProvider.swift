// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

@MainActor
protocol SidebarContentProvider {
    associatedtype Model: PersistentModel where Model.ID == PersistentIdentifier
    associatedtype RowContent: View
    associatedtype MenuContent: View
    associatedtype Coordinator: SidebarCoordinator where
        Coordinator.Model == Model,
        Coordinator.RowContent == RowContent,
        Coordinator.MenuContent == MenuContent

    init(coordinator: Coordinator)

    func modelObjectsDidChange(to newModels: [Model])

    func selectionDidChange(to newSelection: Set<PersistentIdentifier>)
}
