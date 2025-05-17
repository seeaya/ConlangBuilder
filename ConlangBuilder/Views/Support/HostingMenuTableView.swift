// Copyright (c) Connor Barnes. All rights reserved.

import AppKit
import SwiftUI

final class HostingMenuTableView<MenuContent: View>: NSTableView {
    private let content: @MainActor ([Int]?) -> MenuContent?
    private lazy var underlyingMenu = NSHostingMenu(rootView: makeMenuRootView())

    init(content: @MainActor @escaping ([Int]?) -> MenuContent?) {
        self.content = content
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var menu: NSMenu? {
        get {
            underlyingMenu.rootView = makeMenuRootView()
            return underlyingMenu
        }
        set { // swiftlint:disable:this unused_setter_value
            assertionFailure("Cannot assign to HostingMenuTableView.menu")
        }
    }
}

// MARK: - MenuView
private extension HostingMenuTableView {
    struct MenuView: View {
        private let content: MenuContent?

        init(content: MenuContent?) {
            self.content = content
        }

        var body: some View {
            content
        }
    }
}

// MARK: - Helpers
private extension HostingMenuTableView {
    var selectionForContextMenu: [Int]? {
        if clickedRow == -1 {
            // Didn't click on any row, the menu isn't bound to a selection
            nil
        } else if selectedRowIndexes.contains(clickedRow) {
            // Clicked on a selected row, the menu is bound to the selection
            Array(selectedRowIndexes)
        } else {
            // Clicked on an unselected row, the menu is bound to the clicked row only
            [clickedRow]
        }
    }

    func makeMenuRootView() -> MenuView {
        MenuView(content: content(selectionForContextMenu))
    }
}
