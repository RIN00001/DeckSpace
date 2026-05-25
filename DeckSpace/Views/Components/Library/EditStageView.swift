//
//  EditStageView.swift
//  DeckSpace
//

import SwiftUI

struct EditStageView: View {

    @Environment(\.dismiss) private var dismiss

    let stage: Stage
    let onSave: (Stage) async -> Void

    @State private var title: String
    @State private var description: String
    @State private var requiredCorrectRate: Double
    @State private var isSaving = false

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(stage: Stage, onSave: @escaping (Stage) async -> Void) {
        self.stage = stage
        self.onSave = onSave

        _title = State(initialValue: stage.title)
        _description = State(initialValue: stage.description)
        _requiredCorrectRate = State(initialValue: stage.requiredCorrectRate)
    }

    var body: some View {
        Form {
            Section("Stage Information") {
                TextField("Title", text: $title)

                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...5)
            }

            Section("Completion Requirement") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Int(requiredCorrectRate * 100))% required")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Slider(
                        value: $requiredCorrectRate,
                        in: 0.1...1.0,
                        step: 0.05
                    )
                }
            }
        }
        .navigationTitle("Edit Stage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await saveStage()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!canSave || isSaving)
            }
        }
    }

    private func saveStage() async {
        isSaving = true

        var updatedStage = stage
        updatedStage.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedStage.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedStage.requiredCorrectRate = requiredCorrectRate
        updatedStage.updatedAt = Date()

        await onSave(updatedStage)

        isSaving = false
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditStageView(
            stage: Stage(
                id: "stage_001",
                deckId: "deck_001",
                title: "General",
                description: "Default stage",
                orderIndex: 0,
                isUnlocked: true
            )
        ) { _ in }
    }
}
