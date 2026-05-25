//
//  FlashcardDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct FlashcardDetailView: View {
    let deck: Deck
    let stage: Stage
    let flashcard: Flashcard

    @State private var editableFlashcard: Flashcard
    @StateObject private var detailViewModel = FlashcardDetailViewModel()
    @StateObject private var flashcardViewModel = FlashcardViewModel()

    init(deck: Deck, stage: Stage, flashcard: Flashcard) {
        self.deck = deck
        self.stage = stage
        self.flashcard = flashcard
        _editableFlashcard = State(initialValue: flashcard)
    }

    private var deckId: String {
        deck.id ?? ""
    }

    private var stageId: String {
        stage.id ?? ""
    }

    private var flashcardId: String {
        editableFlashcard.id ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                flashcardHeader

                contentSection

                if let errorMessage = detailViewModel.errorMessage {
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
            .padding()
        }
        .navigationTitle(editableFlashcard.type.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchAnswersIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EditFlashcardView(
                        flashcard: editableFlashcard,
                        answers: detailViewModel.answers
                    ) { updatedFlashcard, updatedAnswers in
                        await flashcardViewModel.updateFlashcard(
                            deckId: deckId,
                            stageId: stageId,
                            flashcard: updatedFlashcard,
                            answers: updatedAnswers
                        )

                        editableFlashcard = updatedFlashcard

                        await detailViewModel.fetchAnswers(
                            deckId: deckId,
                            stageId: stageId,
                            flashcardId: flashcardId
                        )
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
    }

    private func fetchAnswersIfNeeded() async {
        if !deckId.isEmpty && !stageId.isEmpty && !flashcardId.isEmpty {
            await detailViewModel.fetchAnswers(
                deckId: deckId,
                stageId: stageId,
                flashcardId: flashcardId
            )
        }
    }

    private var flashcardHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 70, height: 70)

                    Image(systemName: displayIconName)
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(editableFlashcard.type.title)
                        .font(.title2.bold())

                    Text(editableFlashcard.difficultyLevel.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Label("Score \(editableFlashcard.masteryScore)/\(editableFlashcard.masteryThreshold)", systemImage: "chart.bar.fill")

                if editableFlashcard.isMastered {
                    Label("Mastered", systemImage: "checkmark.seal.fill")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Label("\(editableFlashcard.correctCount) correct", systemImage: "checkmark.circle.fill")
                Label("\(editableFlashcard.incorrectCount) wrong", systemImage: "xmark.circle.fill")
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

    @ViewBuilder
    private var contentSection: some View {
        switch editableFlashcard.type {
        case .intro:
            introContent

        case .multipleChoice:
            multipleChoiceContent

        case .paragraph:
            paragraphContent
        }
    }

    private var introContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explanation")
                .font(.headline)

            Text(editableFlashcard.explanationText ?? "No explanation provided.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .libraryContentCardStyle()
    }

    private var multipleChoiceContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Question")
                .font(.headline)

            Text(editableFlashcard.promptText ?? "No question provided.")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("Answers")
                    .font(.headline)

                Spacer()

                if detailViewModel.isLoading {
                    ProgressView()
                }
            }

            if detailViewModel.answers.isEmpty && !detailViewModel.isLoading {
                Text("No answers found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(detailViewModel.answers) { answer in
                        HStack(spacing: 10) {
                            Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(answer.isCorrect ? Color.green : Color.secondary)

                            Text(answer.text)
                                .font(.body)

                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(answer.isCorrect ? Color.green.opacity(0.12) : Color.gray.opacity(0.1))
                        )
                    }
                }
            }
        }
        .libraryContentCardStyle()
    }

    private var paragraphContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Question")
                .font(.headline)

            Text(editableFlashcard.promptText ?? "No question provided.")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            HStack {
                Text("Model Answer")
                    .font(.headline)

                Spacer()

                if detailViewModel.isLoading {
                    ProgressView()
                }
            }

            if let modelAnswer = detailViewModel.answers.first {
                Text(modelAnswer.text)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if !detailViewModel.isLoading {
                Text("No model answer found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .libraryContentCardStyle()
    }

    private var displayIconName: String {
        if let imageIconName = editableFlashcard.imageIconName, !imageIconName.isEmpty {
            return imageIconName
        }

        return editableFlashcard.type.iconName
    }
}

private extension View {
    func libraryContentCardStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.gray.opacity(0.1))
            )
    }
}

#Preview {
    NavigationStack {
        FlashcardDetailView(
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
                orderIndex: 0,
                isUnlocked: true
            ),
            flashcard: Flashcard(
                id: "flashcard_001",
                deckId: "deck_001",
                stageId: "stage_001",
                type: .multipleChoice,
                difficultyLevel: .easy,
                promptText: "What does @State do in SwiftUI?",
                imageIconName: "swift"
            )
        )
    }
}
