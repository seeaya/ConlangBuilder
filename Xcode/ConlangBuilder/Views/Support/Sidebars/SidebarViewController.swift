// Copyright (c) Connor Barnes. All rights reserved.

import AppKit
import SwiftData
import SwiftUI

final class SidebarViewController<
    Model: PersistentModel,
    RowContent: View,
    MenuContent: View,
    Coordinator: SidebarCoordinator
>:
    NSViewController,
    NSTableViewDelegate
where
    Model.ID == PersistentIdentifier,
    Coordinator.Model == Model,
    Coordinator.RowContent == RowContent,
    Coordinator.MenuContent == MenuContent
{ // swiftlint:disable:this opening_brace
    private typealias DataSource = NSTableViewDiffableDataSource<SidebarSectionIdentifier, PersistentIdentifier>

    private let coordinator: Coordinator
    private var lastKnownModels: [Model] = []
    private let selectionProvider = Sidebar<Model, RowContent, MenuContent>.SelectionProvider()
    private lazy var dataSource = makeDataSource()

    private lazy var tableView = makeTableView()
    private lazy var scrollView = makeScrollView()

    private lazy var deleteRowAction = makeDeleteRowAction()

    // MARK: - Initializers
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides
    override func loadView() {
        view = NSView()

        tableView.frame = scrollView.bounds
        scrollView.documentView = tableView
        view.addSubview(scrollView)

        applyConstraints()

        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    override func viewDidLoad() {
        applySnapshot(for: coordinator.models, animatingDifferences: false)
    }

    // MARK: - NSTableViewDelegate
    // Extensions don't support @objc members in generic classes

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        Appearance.rowHeight
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedIdentifiers = tableView.selectedRowIndexes.compactMap { dataSource.itemIdentifier(forRow: $0) }
        coordinator.updateSelection(to: Set(selectedIdentifiers))

        selectionProvider.selection = tableView.selectedRowIndexes.compactMap(model(forRow:))
    }

    func tableView(
        _ tableView: NSTableView,
        rowActionsForRow row: Int,
        edge: NSTableView.RowActionEdge
    ) -> [NSTableViewRowAction] {
        switch edge {
        case .leading:
            []
        case .trailing:
            [deleteRowAction]
        @unknown default:
            []
        }
    }

    func tableView(
        _ tableView: NSTableView,
        typeSelectStringFor tableColumn: NSTableColumn?,
        row: Int
    ) -> String? {
        model(forRow: row).flatMap(coordinator.typeSelectString(forModel:))
    }
}

// MARK: - SidebarSectionIdentifier
private enum SidebarSectionIdentifier: Hashable {
    case primary
}

// MARK: - SidebarContentProvider
extension SidebarViewController: SidebarContentProvider {
    func modelObjectsDidChange(to newModels: [Model]) {
        applySnapshot(for: newModels, animatingDifferences: true)
    }

    func selectionDidChange(to newSelection: Set<PersistentIdentifier>) {
        // Need an early exit, or us modifying the selection would result in an infinite loop of us notifying the coordinator, then the coordinator notifying us
        guard tableSelection != newSelection else { return }

        let newSelectionIndices = newSelection.compactMap(dataSource.row(forItemIdentifier:))

        tableView.selectRowIndexes(IndexSet(newSelectionIndices), byExtendingSelection: false)
    }
}

// MARK: - Subviews
private extension SidebarViewController {
    func makeTableView() -> NSTableView {
        let tableView = HostingMenuTableView<MenuContent> { [weak self] selectionIndices in
            guard let self else { return nil }
            let selection = selectionIndices?.compactMap(self.model(forRow:))
            return self.coordinator.menu(forSelection: selection)
        }
        // Behavior
        tableView.focusRingType = .none
        tableView.allowsMultipleSelection = true

        // Appearance
        tableView.style = .sourceList

        // Columns
        let primaryColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PrimarySidebarColumn"))
        tableView.addTableColumn(primaryColumn)
        tableView.headerView = nil

        return tableView
    }

    func makeScrollView() -> NSScrollView {
        let scrollView = NSScrollView()
        // Behavior
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false

        // Appearance
        scrollView.drawsBackground = false

        return scrollView
    }

    func cell(
        for tableView: NSTableView,
        tableColumn: NSTableColumn,
        row: Int,
        identifier: PersistentIdentifier
    ) -> NSView {
        guard let model = coordinator.model(for: identifier) else { return NSView() }

        return NSHostingView(
            rootView: coordinator.view(forModel: model)
        )
    }
}

// MARK: - Actions
private extension SidebarViewController {
    func makeDeleteRowAction() -> NSTableViewRowAction {
        let action = NSTableViewRowAction(style: .destructive, title: "Delete", handler: deleteRow(_:rowIndex:))

        action.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete")

        return action
    }

    func deleteRow(_ action: NSTableViewRowAction, rowIndex: Int) {
        guard let model = model(forRow: rowIndex) else { return }
        coordinator.delete(models: [model])
    }
}

// MARK: - Helpers
private extension SidebarViewController {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            tableView: tableView,
            cellProvider: cell(for:tableColumn:row:identifier:)
        )

        dataSource.defaultRowAnimation = [.effectFade, .slideDown]

        return dataSource
    }

    func applySnapshot(for newModels: [Model], animatingDifferences: Bool) {
        guard newModels.map(\.id) != lastKnownModels.map(\.id) else { return }
        lastKnownModels = newModels

        var snapshot = NSDiffableDataSourceSnapshot<SidebarSectionIdentifier, PersistentIdentifier>()
        snapshot.appendSections([.primary])
        snapshot.appendItems(newModels.map(\.id), toSection: .primary)

        tableView.beginUpdates()
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            // Scrolling animations don't work well when happening along side table update animations, so just do it after. This isn't ideal but looks better than the alternative
            guard let self else { return }

            MainActor.assumeIsolated {
                guard
                    tableView.selectedRowIndexes.count == 1,
                    let rowToScrollTo = tableView.selectedRowIndexes.first
                else { return }

                guard let superview = tableView.superview else { return }

                let rowRect = tableView.rect(ofRow: rowToScrollTo)
                let viewRect = superview.frame

                var scrollOrigin = rowRect.origin
                scrollOrigin.y += rowRect.size.height - viewRect.size.height
                scrollOrigin.y = max(0, scrollOrigin.y)

                superview.animator().setBoundsOrigin(scrollOrigin)
            }
        }

        tableView.endUpdates()
    }

    func applyConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    var tableSelection: Set<PersistentIdentifier> {
        Set(tableView.selectedRowIndexes.compactMap(dataSource.itemIdentifier(forRow:)))
    }

    func model(forRow rowIndex: Int) -> Model? {
        dataSource.itemIdentifier(forRow: rowIndex).flatMap(coordinator.model(for:))
    }
}

// MARK: - Appearance
/// A namespace for constants related to the appearance of `SidebarViewController`.
enum SidebarAppearance {
    /// The height of each row in the sidebar.
    static let rowHeight = 28.0
}

private typealias Appearance = SidebarAppearance

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
