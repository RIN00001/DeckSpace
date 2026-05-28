//
//  FlashcardDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI
import FirebaseAuth

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

    private var isOwner: Bool {
        deck.ownerId == Auth.auth().currentUser?.uid
    }

    private var canEditFlashcard: Bool {
        isOwner && !deck.isPublished
    }

    var body: some View {
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 860

            ScrollView {
                Group {
                    if isWideLayout {
                        HStack(alignment: .top, spacing: 28) {
                            flashcardHeader
                                .frame(maxWidth: 360)

                            contentColumn
                                .frame(maxWidth: 650)
                        }
                    } else {
                        VStack(spacing: 20) {
                            flashcardHeader

                            contentColumn
                        }
                    }
                }
                .padding(.horizontal, isWideLayout ? 32 : 16)
                .padding(.vertical, 24)
                .frame(maxWidth: 1120)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle(editableFlashcard.type.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchAnswersIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if canEditFlashcard {
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
                                flashcardId: updatedFlashcard.id ?? flashcardId
                            )
                        }
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
    }

    private func fetchAnswersIfNeeded() async {
        guard !deckId.isEmpty,
              !stageId.isEmpty,
              !flashcardId.isEmpty else {
            return
        }

        await detailViewModel.fetchAnswers(
            deckId: deckId,
            stageId: stageId,
            flashcardId: flashcardId
        )
    }

    // MARK: - Main Content

    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: 18) {
            contentSection

            if !canEditFlashcard {
                lockedNotice
            }

            errorSection
        }
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

    private var lockedNotice: some View {
        Label(
            deck.isPublished ? "This deck is published, so this flashcard is view-only." : "Only the owner can edit this flashcard.",
            systemImage: "lock.fill"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if detailViewModel.errorMessage != nil || flashcardViewModel.errorMessage != nil {
            VStack(alignment: .leading, spacing: 8) {
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
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.08))
            )
        }
    }

    // MARK: - Header

    private var flashcardHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 76, height: 76)

                    Image(systemName: displayIconName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(editableFlashcard.type.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    difficultyBadge

                    if editableFlashcard.isMastered {
                        masteredBadge
                    }
                }

                Spacer()
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                metricRow(
                    title: "Order",
                    value: "#\(editableFlashcard.orderIndex + 1)",
                    systemImage: "number"
                )

                metricRow(
                    title: "Mastery Score",
                    value: "\(editableFlashcard.masteryScore)/\(editableFlashcard.masteryThreshold)",
                    systemImage: "chart.bar.fill"
                )

                metricRow(
                    title: "Correct",
                    value: "\(editableFlashcard.correctCount)",
                    systemImage: "checkmark.circle.fill"
                )

                metricRow(
                    title: "Wrong",
                    value: "\(editableFlashcard.incorrectCount)",
                    systemImage: "xmark.circle.fill"
                )
            }
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

    private var difficultyBadge: some View {
        Label(
            editableFlashcard.difficultyLevel.title,
            systemImage: editableFlashcard.difficultyLevel.iconName
        )
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(Capsule())
    }

    private var masteredBadge: some View {
        Label("Mastered", systemImage: "checkmark.seal.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
    }

    private func metricRow(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }

    // MARK: - Intro

    private var introContent: some View {
        contentCard(title: "Explanation", systemImage: "text.alignleft") {
            Text(editableFlashcard.explanationText ?? "No explanation provided.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Multiple Choice

    private var multipleChoiceContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            contentCard(title: "Question", systemImage: "questionmark.circle.fill") {
                Text(editableFlashcard.promptText ?? "No question provided.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            contentCard(title: "Answers", systemImage: "checklist.checked") {
                if detailViewModel.isLoading {
                    loadingAnswerView
                } else if detailViewModel.answers.isEmpty {
                    emptyAnswerView("No answers found.")
                } else {
                    VStack(spacing: 10) {
                        ForEach(detailViewModel.answers) { answer in
                            answerRow(answer)
                        }
                    }
                }
            }
        }
    }

    private func answerRow(_ answer: Answer) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(answer.isCorrect ? .green : .secondary)
                .padding(.top, 1)

            Text(answer.text)
                .font(.body)
                .foregroundStyle(answer.isCorrect ? .primary : .secondary)
                .lineSpacing(2)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(answer.isCorrect ? Color.green.opacity(0.12) : Color(.secondarySystemGroupedBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(answer.isCorrect ? Color.green.opacity(0.25) : Color.clear, lineWidth: 1)
        }
    }

    // MARK: - Paragraph

    private var paragraphContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            contentCard(title: "Question", systemImage: "questionmark.circle.fill") {
                Text(editableFlashcard.promptText ?? "No question provided.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            contentCard(title: "Model Answer", systemImage: "text.alignleft") {
                if detailViewModel.isLoading {
                    loadingAnswerView
                } else if let modelAnswer = detailViewModel.answers.first {
                    Text(modelAnswer.text)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    emptyAnswerView("No model answer found.")
                }
            }
        }
    }

    private var loadingAnswerView: some View {
        HStack(spacing: 10) {
            ProgressView()

            Text("Loading answers...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emptyAnswerView(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Shared Card

    private func contentCard<Content: View>(
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

    private var displayIconName: String {
        if let imageIconName = editableFlashcard.imageIconName, !imageIconName.isEmpty {
            return imageIconName
        }

        return editableFlashcard.type.iconName
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
