// Copyright (c) Connor Barnes. All rights reserved.

import ConlangModels
import SwiftData
import SwiftUI

@MainActor
struct DefinitionEditor {
    @Bindable private var definition: Definition

    @FocusState private var focusedControl: ControlID?

    @State private var partOfSpeech = 0

    init(definition: Definition) {
        self.definition = definition
    }
}

// MARK: - View
extension DefinitionEditor: View {
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("\(definition.index + 1).")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        partOfSpeechPicker
                        pronunciationTextField
                        Spacer()
                        actionButtons
                    }

                    localNameTextField
                    definitionEditor
                }
            }
        }
    }
}

// MARK: - Subviews
private extension DefinitionEditor {
    var partOfSpeechPicker: some View {
        Picker(selection: $partOfSpeech) {
            Text("Noun").tag(0)
            Text("Verb").tag(1)
        } label: {
            EmptyView()
        }
        .buttonStyle(.plain)
        .padding(.leading, Appearance.partOfSpeechLeadingPadding)
        .padding(.trailing, Appearance.partOfSpeechTrailingPadding)
        .fixedSize()
    }

    var localNameTextField: some View {
        TextField("Local Word", text: $definition.localWord)
            .focused($focusedControl, equals: .localWord)
            .fixedSize(horizontal: focusedControl != .localWord, vertical: false)
            .autocorrectionDisabled(false)
    }

    var pronunciationTextField: some View {
        HStack(spacing: 0) {
            Text("|")

            Spacer()
                .frame(width: Appearance.pronunciationLeadingBarSpacing)

            TextField("Pronunciation", text: $definition.pronunciation)
                .focused($focusedControl, equals: .pronunciation)
                .fixedSize(horizontal: focusedControl != .pronunciation, vertical: false)
                .autocorrectionDisabled(true)

            Text("|")
                .offset(x: focusedControl == .pronunciation ? Appearance.pronunciationTrailingBarFocusedSpacing : 0)
        }
        .foregroundStyle(.secondary)
    }

    var definitionEditor: some View {
        TextEditor(text: $definition.definitionDescription)
            .autocorrectionDisabled(false)
            .scrollDisabled(true)
            .padding(.horizontal, Appearance.definitionEditorHorizontalPadding)
            .padding(.bottom, Appearance.definitionEditorBottomPadding)
            .background {
                if definition.definitionDescription.isEmpty {
                    HStack {
                        Text("Definition")
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                }
            }
            .font(.subheadline)
    }

    var actionButtons: some View {
        HStack {
            Button(action: deleteDefinition) {
                Image(systemName: "trash")
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Image(systemName: "line.3.horizontal")
                .contentShape(Rectangle())
                .draggable(DefinitionProxy(for: definition)) {
                    Image(systemName: "note.text")
                }
        }
    }
}

// MARK: - Actions
private extension DefinitionEditor {
    func deleteDefinition() {
        withAnimation(.snappy) {
            definition.delete()
        }
    }
}

// MARK: - ControlID
private enum ControlID: Hashable {
    case localWord
    case pronunciation
}

// MARK: - Appearance
private enum DefinitionEditorAppearance {
    static let definitionEditorHorizontalPadding = -5.0
    static let definitionEditorBottomPadding = 2.0

    static let pronunciationLeadingBarSpacing = 4.0
    static let pronunciationTrailingBarFocusedSpacing = 4.0

    static let partOfSpeechLeadingPadding = -10.0
    static let partOfSpeechTrailingPadding = -5.0
}

private typealias Appearance = DefinitionEditorAppearance

// MARK: - Previews
#Preview {
    PreviewWrapper {
        List {
            DefinitionEditor(definition: .sample1)
        }
        .scrollContentBackground(.hidden)
    }
    .padding()
    .frame(width: 400)
}
