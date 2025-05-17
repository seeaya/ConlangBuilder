// Copyright (c) Connor Barnes. All rights reserved.

import Combine
import SwiftData
import SwiftUI

@MainActor
struct ModelSelectionSidebar<Model: PersistentModel> where Model.ID == PersistentIdentifier {
    @Environment(\.modelContext)
    private var modelContext

    @Binding private var selectedModelIDs: Set<PersistentIdentifier>

    // Avoiding @Query due to slow performance
    @State private var models: [Model] = []

    @State private var didSaveCancellable: AnyCancellable?

    private let titleKeyPath: any ReferenceWritableKeyPath<Model, String> & Sendable

    private let newModel: () -> Model

    init(
        for type: Model.Type = Model.self,
        title titleKeyPath: any ReferenceWritableKeyPath<Model, String> & Sendable,
        selectedModelIDs: Binding<Set<PersistentIdentifier>>,
        newModel: @autoclosure @escaping () -> Model
    ) {
        _selectedModelIDs = selectedModelIDs
        self.titleKeyPath = titleKeyPath
        self.newModel = newModel
    }
}

// MARK: - View
extension ModelSelectionSidebar: View {
    var body: some View {
        VStack {
            Sidebar(models, selection: $selectedModelIDs) { model in
                Text(model[keyPath: titleKeyPath].isEmpty ? "Unnamed" : model[keyPath: titleKeyPath])
                    .foregroundStyle(model[keyPath: titleKeyPath].isEmpty ? .secondary : .primary)
            } menu: { selection in
                contextMenuContent(selection: selection)
            } typeSelectString: { model in
                model[keyPath: titleKeyPath]
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .onDeleteCommand {
            deleteSelectedModels()
        }
        .onAppear {
            didSaveCancellable = NotificationCenter.default.publisher(for: ModelContext.didSave)
                .receive(on: RunLoop.main)
                .sink { _ in
                    fetchModels()
                }

            fetchModels()
        }
    }
}

// MARK: - Subviews
private extension ModelSelectionSidebar {
    var bottomBar: some View {
        BottomBar(backgroundHidden: true) {
            Menu {
                // swiftlint:disable:next no_magic_numbers
                let counts = [10, 100, 1_000, 10_000, 100_000, 1_000_000]

                ForEach(counts, id: \.self) { count in
                    Button("Create \(count, format: .number)") {
                        createNewModels(count: count)
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
            } primaryAction: {
                createNewModel()
            }

            Button(action: deleteSelectedModels) {
                Image(systemName: "minus")
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .disabled(selectedModelIDs.isEmpty)

            Spacer()
        }
    }

    @ViewBuilder
    func contextMenuContent(selection: [Model]?) -> some View {
        if let selection {
            Button("Delete") {
                print("DELETE")
                delete(models: selection)
            }
        }
    }
}

// MARK: - Actions
private extension ModelSelectionSidebar {
    func createNewModel() {
        let model = newModel()
        modelContext.insert(model)
        try? modelContext.save()

        selectedModelIDs = [model.id]
    }

    func createNewModels(count: Int) {
        (0..<count).forEach { index in
            let model = newModel()
            model[keyPath: titleKeyPath] = "\(index + 1)"
            modelContext.insert(model)
        }

        try? modelContext.save()
    }

    func deleteSelectedModels() {
        let modelsToDelete = selectedModels
        selectedModelIDs = []

        // TODO: Batch
        modelsToDelete.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }

    func delete(modelsWithIDs ids: Set<PersistentIdentifier>) {
        let models = ids.compactMap { modelContext.model(for: $0) as? Model }
        delete(models: models)
    }

    func delete(models: [Model]) {
        selectedModelIDs.subtract(models.map(\.id))
        // TODO: Batch
        models.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}

// MARK: - Helpers
private extension ModelSelectionSidebar {
    var selectedModels: some Collection<Model> {
        selectedModelIDs.compactMap { modelContext.model(for: $0) as? Model }
    }

    var selectedModel: Model? {
        guard
            selectedModelIDs.count == 1,
            let selectedID = selectedModelIDs.first,
            let model = modelContext.registeredModel(for: selectedID) as Model?
        else { return nil }

        return model
    }

    func fetchModels() {
        var fetchDescriptor = FetchDescriptor<Model>(sortBy: [SortDescriptor(titleKeyPath)])
        fetchDescriptor.includePendingChanges = false

        var newModelIDs: [PersistentIdentifier] = []

        var duration = ContinuousClock().measure {
            newModelIDs = (try? modelContext.fetchIdentifiers(fetchDescriptor)) ?? []
        }
        print("Fetch: \(duration)")

        var newModels: [Model] = []

        duration = ContinuousClock().measure {
            newModels = newModelIDs.compactMap { modelContext.model(for: $0) as? Model }
        }
        print("Type conversion: \(duration)")

        self.models = newModels
    }
}

// MARK: - Previews
#Preview {
    @Previewable @State var selectedModelIDs: Set<PersistentIdentifier> = []

    PreviewWrapper {
        NavigationSplitView {
            ModelSelectionSidebar(
                for: Word.self,
                title: \.conWord,
                selectedModelIDs: $selectedModelIDs,
                newModel: Word()
            )
        } detail: {
            Text("Detail")
        }
    }
}
