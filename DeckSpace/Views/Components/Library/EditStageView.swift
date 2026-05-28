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

    private let maxContentWidth: CGFloat = 1000

    private var canSave: Bool {
        !cleanTitle.isEmpty
    }

    init(stage: Stage, onSave: @escaping (Stage) async -> Void) {
        self.stage = stage
        self.onSave = onSave

        _title = State(initialValue: stage.title)
        _description = State(initialValue: stage.description)
        _requiredCorrectRate = State(initialValue: stage.requiredCorrectRate)
    }

    var body: some View {
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 820

            ScrollView {
                Group {
                    if isWideLayout {
                        HStack(alignment: .top, spacing: 28) {
                            previewCard
                                .frame(maxWidth: 340)

                            editForm
                                .frame(maxWidth: 560)
                        }
                    } else {
                        VStack(spacing: 20) {
                            previewCard

                            editForm
                        }
                    }
                }
                .padding(.horizontal, isWideLayout ? 32 : 16)
                .padding(.vertical, 24)
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
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

    // MARK: - Preview

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(stageIconBackgroundColor)
                        .frame(width: 72, height: 72)

                    Image(systemName: stageIconName)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(stageIconForegroundColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stage \(stage.orderIndex + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(cleanTitle.isEmpty ? "Stage Title" : cleanTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    statusBadge
                }

                Spacer()
            }

            Text(cleanDescription.isEmpty ? "Stage description will appear here." : cleanDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Label("\(Int(requiredCorrectRate * 100))% required to complete", systemImage: "target")

                Label("\(Int(stage.bestCorrectRate * 100))% best correct rate", systemImage: "chart.line.uptrend.xyaxis")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private var stageIconName: String {
        if stage.isCompleted {
            return "checkmark"
        }

        if stage.isUnlocked {
            return "lock.open.fill"
        }

        return "lock.fill"
    }

    private var stageIconBackgroundColor: Color {
        if stage.isCompleted {
            return Color.green.opacity(0.18)
        }

        if stage.isUnlocked {
            return Color.accentColor.opacity(0.18)
        }

        return Color.gray.opacity(0.16)
    }

    private var stageIconForegroundColor: Color {
        if stage.isCompleted {
            return .green
        }

        if stage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    private var statusTitle: String {
        if stage.isCompleted {
            return "Completed"
        }

        if stage.isUnlocked {
            return "Unlocked"
        }

        return "Locked"
    }

    private var statusColor: Color {
        if stage.isCompleted {
            return .green
        }

        if stage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    // MARK: - Form

    private var editForm: some View {
        VStack(spacing: 18) {
            stageInformationSection

            completionRequirementSection
        }
    }

    private var stageInformationSection: some View {
        formCard(title: "Stage Information", systemImage: "rectangle.stack.fill") {
            VStack(spacing: 14) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Description", text: $description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
            }
        }
    }

    private var completionRequirementSection: some View {
        formCard(title: "Completion Requirement", systemImage: "target") {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(Int(requiredCorrectRate * 100))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("required")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()
                }

                Slider(
                    value: $requiredCorrectRate,
                    in: 0.1...1.0,
                    step: 0.05
                )

                HStack {
                    Text("Easy")
                    Spacer()
                    Text("Strict")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text("A stage is completed when the user reaches this correct answer rate during study.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
        }
    }

    private func formCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }

    // MARK: - Logic

    private func saveStage() async {
        isSaving = true

        var updatedStage = stage
        updatedStage.title = cleanTitle
        updatedStage.description = cleanDescription
        updatedStage.requiredCorrectRate = requiredCorrectRate
        updatedStage.updatedAt = Date()

        await onSave(updatedStage)

        isSaving = false
        dismiss()
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
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
