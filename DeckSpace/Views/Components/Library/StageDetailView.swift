//
//  StageDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI
import FirebaseAuth

struct StageDetailView: View {
    let deck: Deck
    let stage: Stage

    @State private var editableStage: Stage
    @State private var editMode: EditMode = .inactive

    @StateObject private var stageViewModel = StageViewModel()
    @StateObject private var flashcardViewModel = FlashcardViewModel()

    init(deck: Deck, stage: Stage) {
        self.deck = deck
        self.stage = stage
        _editableStage = State(initialValue: stage)
    }

    private var deckId: String {
        deck.id ?? ""
    }

    private var stageId: String {
        editableStage.id ?? ""
    }

    private var isOwner: Bool {
        deck.ownerId == Auth.auth().currentUser?.uid
    }

    private var canEditStage: Bool {
        isOwner && !deck.isPublished
    }
    
    private var sortedFlashcards: [Flashcard] {
        flashcardViewModel.flashcards.sorted { $0.orderIndex < $1.orderIndex }
    }

    var body: some View {
        List {
            Section {
                stageHeader
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if canEditStage {
                Section {
                    _FlashcardFormView(
                        viewModel: flashcardViewModel,
                        deckId: deckId,
                        stageId: stageId
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }

            Section {
                flashcardSectionHeader

                if flashcardViewModel.flashcards.isEmpty && !flashcardViewModel.isLoading {
                    emptyFlashcardView
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(sortedFlashcards) { flashcard in
                        NavigationLink {
                            FlashcardDetailView(
                                deck: deck,
                                stage: editableStage,
                                flashcard: flashcard
                            )
                        } label: {
                            _FlashcardRowView(flashcard: flashcard)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            EdgeInsets(
                                top: 6,
                                leading: 16,
                                bottom: 6,
                                trailing: 16
                            )
                        )
                        .contextMenu {
                            if canEditStage {
                                Button(role: .destructive) {
                                    Task {
                                        await flashcardViewModel.deleteFlashcard(
                                            deckId: deckId,
                                            stageId: stageId,
                                            flashcard: flashcard
                                        )
                                    }
                                } label: {
                                    Label("Delete Flashcard", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onMove { source, destination in
                        guard canEditStage else { return }

                        Task {
                            await flashcardViewModel.moveFlashcard(
                                deckId: deckId,
                                stageId: stageId,
                                from: source,
                                to: destination
                            )

                            await flashcardViewModel.fetchFlashcards(
                                deckId: deckId,
                                stageId: stageId
                            )
                        }
                    }
                    .moveDisabled(!canEditStage)
                }
            }

            errorSection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.editMode, $editMode)
        .navigationTitle(editableStage.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty && !stageId.isEmpty {
                await flashcardViewModel.fetchFlashcards(
                    deckId: deckId,
                    stageId: stageId
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if canEditStage {
                    NavigationLink {
                        EditStageView(stage: editableStage) { updatedStage in
                            await stageViewModel.updateStage(
                                deckId: deckId,
                                stage: updatedStage
                            )

                            editableStage = updatedStage
                        }
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Reorder")
                    }
                    .disabled(flashcardViewModel.flashcards.count <= 1)
                }
            }
        }
    }

    // MARK: - Header

    private var stageHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(stageIconBackgroundColor)
                        .frame(width: 68, height: 68)

                    Image(systemName: stageIconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(stageIconForegroundColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stage \(editableStage.orderIndex + 1)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(editableStage.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    statusBadge
                }

                Spacer()
            }

            if !editableStage.description.isEmpty {
                Text(editableStage.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }

            HStack(spacing: 12) {
                stageInfoPill(
                    title: "\(Int(editableStage.requiredCorrectRate * 100))% required",
                    systemImage: "target"
                )

                stageInfoPill(
                    title: "\(Int(editableStage.bestCorrectRate * 100))% best",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }

            if !canEditStage {
                Text(deck.isPublished ? "This deck is published, so flashcards are locked from editing." : "Only the owner can edit this stage.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
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

    private func stageInfoPill(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }

    private var stageIconName: String {
        if editableStage.isCompleted {
            return "checkmark"
        }

        if editableStage.isUnlocked {
            return "lock.open.fill"
        }

        return "lock.fill"
    }

    private var stageIconBackgroundColor: Color {
        if editableStage.isCompleted {
            return Color.green.opacity(0.18)
        }

        if editableStage.isUnlocked {
            return Color.accentColor.opacity(0.18)
        }

        return Color.gray.opacity(0.16)
    }

    private var stageIconForegroundColor: Color {
        if editableStage.isCompleted {
            return .green
        }

        if editableStage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    private var statusTitle: String {
        if editableStage.isCompleted {
            return "Completed"
        }

        if editableStage.isUnlocked {
            return "Unlocked"
        }

        return "Locked"
    }

    private var statusColor: Color {
        if editableStage.isCompleted {
            return .green
        }

        if editableStage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    // MARK: - Flashcards

    private var flashcardSectionHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Flashcards")
                    .font(.title3.bold())

                Text(canEditStage ? "Drag to reorder when Reorder mode is active." : "Flashcards are view-only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if flashcardViewModel.isLoading {
                ProgressView()
            }
        }
        .padding(.vertical, 6)
    }

    private var emptyFlashcardView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(spacing: 5) {
                Text("No flashcards yet")
                    .font(.headline)

                Text(canEditStage ? "Add an intro, multiple choice, or paragraph card to this stage." : "This stage does not have flashcards yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    // MARK: - Errors

    @ViewBuilder
    private var errorSection: some View {
        if stageViewModel.errorMessage != nil ||
            flashcardViewModel.errorMessage != nil {

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if let errorMessage = stageViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    if let errorMessage = flashcardViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StageDetailView(
            deck: Deck(
                id: "deck_001",
                ownerId: "user_001",
                ownerName: "Calamity",
                title: "SwiftUI Basics",
                description: "Learn SwiftUI using flashcards.",
                category: "Programming",
                coverIconName: "swift",
                stageCount: 1,
                isPublished: false,
                originalCreatorId: "user_001",
                originalCreatorName: "Calamity",
                originalDeckId: "deck_001",
                originalDeckTitle: "SwiftUI Basics"
            ),
            stage: Stage(
                id: "stage_001",
                deckId: "deck_001",
                title: "General",
                description: "Default stage",
                orderIndex: 0,
                isUnlocked: true
            )
        )
    }
}
