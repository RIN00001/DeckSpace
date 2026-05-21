//
//  FlashcardViewmodel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import Combine
@MainActor
final class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var selectedType: FlashcardType = .intro
    @Published var selectedDifficulty: DifficultyLevel = .easy

    @Published var promptText = ""
    @Published var explanationText = ""
    @Published var imageIconName = ""

    @Published var multipleChoiceAnswers: [AnswerDraft] = [
        AnswerDraft(text: "", isCorrect: true),
        AnswerDraft(text: "", isCorrect: false),
        AnswerDraft(text: "", isCorrect: false),
        AnswerDraft(text: "", isCorrect: false)
    ]

    @Published var paragraphModelAnswer = ""

    private let flashcardService = FlashcardService()

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var canCreateFlashcard: Bool {
        switch selectedType {
        case .intro:
            return !explanationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        case .multipleChoice:
            let filledAnswers = multipleChoiceAnswers.filter {
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            let correctAnswers = multipleChoiceAnswers.filter {
                $0.isCorrect &&
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            return !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            filledAnswers.count >= 2 &&
            correctAnswers.count == 1

        case .paragraph:
            return !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !paragraphModelAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    func fetchFlashcards(deckId: String, stageId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            flashcards = try await flashcardService.fetchFlashcards(
                userId: userId,
                deckId: deckId,
                stageId: stageId
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createFlashcard(deckId: String, stageId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard canCreateFlashcard else {
            errorMessage = "Please complete the flashcard fields correctly."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let finalAnswers = makeAnswerDrafts()
            let finalImageIconName = imageIconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : imageIconName.trimmingCharacters(in: .whitespacesAndNewlines)

            try await flashcardService.createFlashcard(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                type: selectedType,
                orderIndex: flashcards.count,
                difficultyLevel: selectedDifficulty,
                promptText: makePromptText(),
                explanationText: makeExplanationText(),
                imageIconName: finalImageIconName,
                answers: finalAnswers
            )

            resetForm()
            await fetchFlashcards(deckId: deckId, stageId: stageId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteFlashcard(deckId: String, stageId: String, flashcard: Flashcard) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard let flashcardId = flashcard.id else {
            errorMessage = "Flashcard ID is missing."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await flashcardService.deleteFlashcard(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                flashcardId: flashcardId
            )

            flashcards.removeAll { $0.id == flashcardId }
            await reorderFlashcards(deckId: deckId, stageId: stageId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func moveFlashcard(deckId: String, stageId: String, from source: IndexSet, to destination: Int) async {
        let movingFlashcards = source.map { flashcards[$0] }

        for index in source.sorted(by: >) {
            flashcards.remove(at: index)
        }

        let removedBeforeDestination = source.filter { $0 < destination }.count
        let adjustedDestination = max(0, min(destination - removedBeforeDestination, flashcards.count))

        flashcards.insert(contentsOf: movingFlashcards, at: adjustedDestination)

        await reorderFlashcards(deckId: deckId, stageId: stageId)
    }

    func reorderFlashcards(deckId: String, stageId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        do {
            try await flashcardService.reorderFlashcards(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                flashcards: flashcards
            )

            await fetchFlashcards(deckId: deckId, stageId: stageId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setCorrectAnswer(_ answer: AnswerDraft) {
        multipleChoiceAnswers = multipleChoiceAnswers.map { currentAnswer in
            AnswerDraft(
                text: currentAnswer.text,
                isCorrect: currentAnswer.id == answer.id
            )
        }
    }

    private func makePromptText() -> String? {
        switch selectedType {
        case .intro:
            return nil
        case .multipleChoice, .paragraph:
            return promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func makeExplanationText() -> String? {
        switch selectedType {
        case .intro:
            return explanationText.trimmingCharacters(in: .whitespacesAndNewlines)
        case .multipleChoice:
            return nil
        case .paragraph:
            return nil
        }
    }

    private func makeAnswerDrafts() -> [AnswerDraft] {
        switch selectedType {
        case .intro:
            return []

        case .multipleChoice:
            return multipleChoiceAnswers
                .map {
                    AnswerDraft(
                        text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        isCorrect: $0.isCorrect
                    )
                }
                .filter { !$0.text.isEmpty }

        case .paragraph:
            return [
                AnswerDraft(
                    text: paragraphModelAnswer.trimmingCharacters(in: .whitespacesAndNewlines),
                    isCorrect: true
                )
            ]
        }
    }

    func resetForm() {
        selectedType = .intro
        selectedDifficulty = .easy
        promptText = ""
        explanationText = ""
        imageIconName = ""

        multipleChoiceAnswers = [
            AnswerDraft(text: "", isCorrect: true),
            AnswerDraft(text: "", isCorrect: false),
            AnswerDraft(text: "", isCorrect: false),
            AnswerDraft(text: "", isCorrect: false)
        ]

        paragraphModelAnswer = ""
    }
}
