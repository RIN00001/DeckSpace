//
//  DeckService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class DeckService {
    private let db = Firestore.firestore()

    private func userDeckCollection(userId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("decks")
    }

    private func stageCollection(userId: String, deckId: String) -> CollectionReference {
        userDeckCollection(userId: userId)
            .document(deckId)
            .collection("stages")
    }

    func fetchDecks(for userId: String) async throws -> [Deck] {
        let snapshot = try await userDeckCollection(userId: userId)
            .order(by: "updatedAt", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Deck.self)
        }
    }

    func createDeck(
        ownerId: String,
        ownerName: String,
        title: String,
        description: String,
        category: String,
        coverIconName: String,
        isScheduled: Bool,
        scheduledDays: [String],
        scheduledTime: String?
    ) async throws {
        let deckRef = userDeckCollection(userId: ownerId).document()
        let now = Date()

        let deck = Deck(
            id: deckRef.documentID,
            ownerId: ownerId,
            ownerName: ownerName,
            title: title,
            description: description,
            category: category,
            coverImageUrl: nil,
            coverIconName: coverIconName,
            stageCount: 1,
            currentStageId: nil,
            isScheduled: isScheduled,
            scheduledDays: scheduledDays,
            scheduledTime: scheduledTime,
            isPublished: false,
            isDownloadedCopy: false,
            isRemix: false,
            originalCreatorId: ownerId,
            originalCreatorName: ownerName,
            originalDeckId: deckRef.documentID,
            originalDeckTitle: title,
            sourceOwnerId: nil,
            sourceOwnerName: nil,
            sourceDeckId: nil,
            sourceDeckTitle: nil,
            remixNote: nil,
            downloadCount: 0,
            createdAt: now,
            updatedAt: now,
            publishedAt: nil
        )

        try deckRef.setData(from: deck)

        let stageRef = stageCollection(userId: ownerId, deckId: deckRef.documentID).document()
        let defaultStage = Stage(
            id: stageRef.documentID,
            deckId: deckRef.documentID,
            title: "General",
            description: "Default stage",
            orderIndex: 0,
            isUnlocked: true,
            isCompleted: false,
            requiredCorrectRate: 0.7,
            bestCorrectRate: 0.0,
            lastCompletedAt: nil,
            createdAt: now,
            updatedAt: now
        )

        try stageRef.setData(from: defaultStage)

        try await deckRef.updateData([
            "currentStageId": stageRef.documentID,
            "updatedAt": now
        ])
    }

    func updateDeck(
        userId: String,
        deck: Deck
    ) async throws {
        guard let deckId = deck.id else {
            throw DeckServiceError.missingDeckId
        }

        var updatedDeck = deck
        updatedDeck.updatedAt = Date()

        try userDeckCollection(userId: userId)
            .document(deckId)
            .setData(from: updatedDeck, merge: true)
    }

    func deleteDeck(
        userId: String,
        deckId: String
    ) async throws {
        try await userDeckCollection(userId: userId)
            .document(deckId)
            .delete()
    }
}

enum DeckServiceError: LocalizedError {
    case missingDeckId

    var errorDescription: String? {
        switch self {
        case .missingDeckId:
            return "Deck ID is missing."
        }
    }
}
