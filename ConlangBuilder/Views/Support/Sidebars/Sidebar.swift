// Copyright (c) Connor Barnes. All rights reserved.

import SwiftData
import SwiftUI

struct Sidebar<
    Model: PersistentModel,
    RowContent: View,
    MenuContent: View
>: View where Model.ID == PersistentIdentifier {
    @Binding private var selection: Set<PersistentIdentifier>

    @Environment(\.modelContext)
    private var modelContext

    private let rowContent: (Model) -> RowContent
    private let menuContent: ([Model]?) -> MenuContent
    private let typeSelectString: (Model) -> String?
    private let data: [Model]

    init(
        _ data: [Model],
        selection: Binding<Set<PersistentIdentifier>>,
        @ViewBuilder rowContent: @escaping (Model) -> RowContent,
        @ViewBuilder menu: @escaping (_ selection: [Model]?) -> MenuContent,
        typeSelectString: @escaping (Model) -> String?
    ) {
        _selection = selection
        self.rowContent = rowContent
        self.menuContent = menu
        self.typeSelectString = typeSelectString
        self.data = data
    }

    var body: some View {
        SidebarHostingView(
            data,
            selection: $selection,
            modelContext: modelContext,
            typeSelectString: typeSelectString,
            rowContent: { Cell(model: $0, rowContent: rowContent) },
            menuContent: menuContent
        )
    }
}

// MARK: - SidebarHostingView
private struct SidebarHostingView<
    Model: PersistentModel,
    RowContent: View,
    MenuContent: View
> where Model.ID == PersistentIdentifier {
    typealias NSViewControllerType = SidebarViewController<
        Model,
        RowContent,
        MenuContent,
        DefaultSidebarCoordinator<Model, RowContent, MenuContent>
    >

    typealias Coordinator = DefaultSidebarCoordinator<Model, RowContent, MenuContent>

    @Binding var selection: Set<PersistentIdentifier>

    let rowContent: (Model) -> RowContent
    let menuContent: ([Model]?) -> MenuContent
    let typeSelectString: (Model) -> String?
    let data: [Model]
    let modelContext: ModelContext

    init(
        _ data: [Model],
        selection: Binding<Set<PersistentIdentifier>>,
        modelContext: ModelContext,
        typeSelectString: @escaping (Model) -> String?,
        rowContent: @escaping (Model) -> RowContent,
        menuContent: @escaping ([Model]?) -> MenuContent
    ) {
        _selection = selection
        self.rowContent = rowContent
        self.menuContent = menuContent
        self.typeSelectString = typeSelectString
        self.data = data
        self.modelContext = modelContext
    }
}

// MARK: - SidebarHostingView + NSViewControllerRepresentable
extension SidebarHostingView: NSViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSViewController(context: Context) -> NSViewControllerType {
        SidebarViewController(coordinator: context.coordinator)
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.modelObjectsDidChange(to: data)
        nsViewController.selectionDidChange(to: selection)
    }
}

// MARK: - DefaultSidebarCoordinator
@MainActor
private final class DefaultSidebarCoordinator<
    Model: PersistentModel,
    RowContent: View,
    MenuContent: View
> where Model.ID == PersistentIdentifier {
    private let parent: SidebarHostingView<Model, RowContent, MenuContent>

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(_ parent: SidebarHostingView<Model, RowContent, MenuContent>) {
        self.parent = parent
    }
}

// MARK: - DefaultSidebarCoordinator + SidebarCoordinator
extension DefaultSidebarCoordinator: SidebarCoordinator {
    func updateSelection(to newSelection: Set<PersistentIdentifier>) {
        parent.selection = newSelection
    }

    func view(forModel model: Model) -> RowContent {
        parent.rowContent(model)
    }

    func menu(forSelection selection: [Model]?) -> MenuContent {
        parent.menuContent(selection)
    }

    func model(for persistentIdentifier: PersistentIdentifier) -> Model? {
        parent.modelContext.model(for: persistentIdentifier) as? Model
    }

    func typeSelectString(forModel model: Model) -> String? {
        parent.typeSelectString(model)
    }

    func delete(models: [Model]) {
        models.forEach { parent.modelContext.delete($0) }
        try? parent.modelContext.save()

        parent.selection.subtract(models.map(\.persistentModelID))
    }

    var models: [Model] {
        parent.data
    }
}

// MARK: - Previews

#Preview {
    PreviewWrapper {
        SidebarPreview(useNative: false)
    }
}

#Preview {
    PreviewWrapper {
        SidebarPreview(useNative: true)
    }
}
