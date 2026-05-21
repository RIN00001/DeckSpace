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

    @StateObject private var flashcardViewModel = FlashcardViewModel()

    private var deckId: String {
        deck.id ?? ""
    }

    private var stageId: String {
        stage.id ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                stageHeader

                _FlashcardFormView(
                    viewModel: flashcardViewModel,
                    deckId: deckId,
                    stageId: stageId
                )

                flashcardSection

                if let errorMessage = flashcardViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(stage.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty && !stageId.isEmpty {
                await flashcardViewModel.fetchFlashcards(deckId: deckId, stageId: stageId)
            }
        }
    }

    private var stageHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(stage.isUnlocked ? Color.accentColor.opacity(0.16) : Color.gray.opacity(0.16))
                        .frame(width: 56, height: 56)

                    Image(systemName: stage.isUnlocked ? "lock.open.fill" : "lock.fill")
                        .font(.title3)
                        .foregroundStyle(stage.isUnlocked ? Color.accentColor : Color.secondary)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Stage \(stage.orderIndex + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(stage.title)
                        .font(.title2.bold())
                }

                Spacer()
            }

            if !stage.description.isEmpty {
                Text(stage.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Label("\(Int(stage.requiredCorrectRate * 100))% required", systemImage: "target")
                Label("\(Int(stage.bestCorrectRate * 100))% best", systemImage: "chart.line.uptrend.xyaxis")
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

    private var flashcardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Flashcards")
                    .font(.title3.bold())

                Spacer()

                if flashcardViewModel.isLoading {
                    ProgressView()
                }
            }

            if flashcardViewModel.flashcards.isEmpty && !flashcardViewModel.isLoading {
                Text("No flashcard yet. Add an intro, multiple choice, or paragraph card.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(flashcardViewModel.flashcards) { flashcard in
                        NavigationLink {
                            FlashcardDetailView(
                                deck: deck,
                                stage: stage,
                                flashcard: flashcard
                            )
                        } label: {
                            _FlashcardRowView(flashcard: flashcard)
                        }
                        .buttonStyle(.plain)
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
