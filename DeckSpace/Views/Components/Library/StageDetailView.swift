//
//  StageDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

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

    var body: some View {
        List {
            Section {
                stageHeader
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

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

            Section {
                flashcardSectionHeader

                if flashcardViewModel.flashcards.isEmpty && !flashcardViewModel.isLoading {
                    Text("No flashcard yet. Add an intro, multiple choice, or paragraph card.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(flashcardViewModel.flashcards) { flashcard in
                        NavigationLink {
                            FlashcardDetailView(
                                deck: deck,
                                stage: editableStage,
                                flashcard: flashcard
                            )
                        } label: {
                            _FlashcardRowView(flashcard: flashcard)
                        }
                        .contextMenu {
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
                    .onMove { source, destination in
                        Task {
                            await flashcardViewModel.moveFlashcard(
                                deckId: deckId,
                                stageId: stageId,
                                from: source,
                                to: destination
                            )
                        }
                    }
                }
            }

            if let errorMessage = stageViewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            if let errorMessage = flashcardViewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .navigationTitle(editableStage.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty && !stageId.isEmpty {
                await flashcardViewModel.fetchFlashcards(deckId: deckId, stageId: stageId)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
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
            }
        }
    }

    private var stageHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(editableStage.isUnlocked ? Color.accentColor.opacity(0.16) : Color.gray.opacity(0.16))
                        .frame(width: 56, height: 56)

                    Image(systemName: editableStage.isUnlocked ? "lock.open.fill" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(editableStage.isUnlocked ? Color.accentColor : Color.secondary)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Stage \(editableStage.orderIndex + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(editableStage.title)
                        .font(.title2.bold())
                }

                Spacer()
            }

            if !editableStage.description.isEmpty {
                Text(editableStage.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Label("\(Int(editableStage.requiredCorrectRate * 100))% required", systemImage: "target")
                Label("\(Int(editableStage.bestCorrectRate * 100))% best", systemImage: "chart.line.uptrend.xyaxis")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
        )
    }

    private var flashcardSectionHeader: some View {
        HStack {
            Text("Flashcards")
                .font(.title3.bold())

            Spacer()

            if flashcardViewModel.isLoading {
                ProgressView()
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
