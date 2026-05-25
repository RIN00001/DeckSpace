//
//  FlashcardService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

final class FlashcardService {
    private let db = Firestore.firestore()

    private func stageDocument(
        userId: String,
        deckId: String,
        stageId: String
    ) -> DocumentReference {
        db.collection("users")
            .document(userId)
            .collection("decks")
            .document(deckId)
            .collection("stages")
            .document(stageId)
    }

    private func flashcardCollection(
        userId: String,
        deckId: String,
        stageId: String
    ) -> CollectionReference {
        stageDocument(userId: userId, deckId: deckId, stageId: stageId)
            .collection("flashcards")
    }

    private func answerCollection(
        userId: String,
        deckId: String,
        stageId: String,
        flashcardId: String
    ) -> CollectionReference {
        flashcardCollection(userId: userId, deckId: deckId, stageId: stageId)
            .document(flashcardId)
            .collection("answers")
    }

    func fetchFlashcards(
        userId: String,
        deckId: String,
        stageId: String
    ) async throws -> [Flashcard] {
        let snapshot = try await flashcardCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .order(by: "orderIndex")
        .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Flashcard.self)
        }
    }

    func fetchAnswers(
        userId: String,
        deckId: String,
        stageId: String,
        flashcardId: String
    ) async throws -> [Answer] {
        let snapshot = try await answerCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId,
            flashcardId: flashcardId
        )
        .order(by: "orderIndex")
        .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Answer.self)
        }
    }

    func createFlashcard(
        userId: String,
        deckId: String,
        stageId: String,
        type: FlashcardType,
        orderIndex: Int,
        difficultyLevel: DifficultyLevel,
        promptText: String?,
        explanationText: String?,
        imageIconName: String?,
        answers: [AnswerDraft]
    ) async throws {
        let now = Date()

        let flashcardRef = flashcardCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .document()

        let flashcard = Flashcard(
            id: flashcardRef.documentID,
            deckId: deckId,
            stageId: stageId,
            type: type,
            orderIndex: orderIndex,
            difficultyLevel: difficultyLevel,
            promptText: promptText,
            explanationText: explanationText,
            imageUrl: nil,
            imageIconName: imageIconName,
            masteryScore: 0,
            masteryThreshold: 8,
            isMastered: false,
            correctCount: 0,
            incorrectCount: 0,
            correctStreak: 0,
            lastReviewedAt: nil,
            createdAt: now,
            updatedAt: now
        )

        try flashcardRef.setData(from: flashcard)

        for (index, answerDraft) in answers.enumerated() {
            let answerRef = answerCollection(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                flashcardId: flashcardRef.documentID
            )
            .document()

            let answer = Answer(
                id: answerRef.documentID,
                flashcardId: flashcardRef.documentID,
                text: answerDraft.text,
                isCorrect: answerDraft.isCorrect,
                orderIndex: index
            )

            try answerRef.setData(from: answer)
        }

        try await stageDocument(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .updateData([
            "updatedAt": now
        ])
    }

    func deleteFlashcard(
        userId: String,
        deckId: String,
        stageId: String,
        flashcardId: String
    ) async throws {
        try await flashcardCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .document(flashcardId)
        .delete()

        try await stageDocument(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .updateData([
            "updatedAt": Date()
        ])
    }

    func reorderFlashcards(
        userId: String,
        deckId: String,
        stageId: String,
        flashcards: [Flashcard]
    ) async throws {
        let batch = db.batch()
        let now = Date()

        for (index, flashcard) in flashcards.enumerated() {
            guard let flashcardId = flashcard.id else { continue }

            let ref = flashcardCollection(
                userId: userId,
                deckId: deckId,
                stageId: stageId
            )
            .document(flashcardId)

            batch.updateData([
                "orderIndex": index,
                "updatedAt": now
            ], forDocument: ref)
        }

        batch.updateData([
            "updatedAt": now
        ], forDocument: stageDocument(userId: userId, deckId: deckId, stageId: stageId))

        try await batch.commit()
    }
    
    func updateFlashcard(
        userId: String,
        deckId: String,
        stageId: String,
        flashcard: Flashcard,
        answers: [AnswerDraft]
    ) async throws {
        guard let flashcardId = flashcard.id else {
            throw FlashcardServiceError.missingFlashcardId
        }

        let now = Date()

        var updatedFlashcard = flashcard
        updatedFlashcard.updatedAt = now

        let flashcardRef = flashcardCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId
        )
        .document(flashcardId)

        try flashcardRef.setData(from: updatedFlashcard, merge: true)

        let oldAnswersSnapshot = try await answerCollection(
            userId: userId,
            deckId: deckId,
            stageId: stageId,
            flashcardId: flashcardId
        )
        .getDocuments()

        let batch = db.batch()

        for document in oldAnswersSnapshot.documents {
            batch.deleteDocument(document.reference)
        }

        for (index, answerDraft) in answers.enumerated() {
            let answerRef = answerCollection(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                flashcardId: flashcardId
            )
            .document()

            let answer = Answer(
                id: answerRef.documentID,
                flashcardId: flashcardId,
                text: answerDraft.text,
                isCorrect: answerDraft.isCorrect,
                orderIndex: index
            )

            try batch.setData(from: answer, forDocument: answerRef)
        }

        batch.updateData([
            "updatedAt": now
        ], forDocument: stageDocument(userId: userId, deckId: deckId, stageId: stageId))

        try await batch.commit()
    }
}

struct AnswerDraft: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isCorrect: Bool
}

enum FlashcardServiceError: LocalizedError {
    case missingFlashcardId

    var errorDescription: String? {
        switch self {
        case .missingFlashcardId:
            return "Flashcard ID is missing."
        }
    }
}
