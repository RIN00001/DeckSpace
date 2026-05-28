//
//  StageService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

final class StageService {
    private let db = Firestore.firestore()

    // MARK: - Helper Collection Reference
    private func stageCollection(userId: String, deckId: String) -> CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("decks")
            .document(deckId)
            .collection("stages")
    }

    // MARK: - Personal Decks Stages
    func fetchStages(userId: String, deckId: String) async throws -> [Stage] {
        let snapshot = try await stageCollection(userId: userId, deckId: deckId)
            .order(by: "orderIndex", descending: false)
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Stage.self)
        }
    }

    func createStage(userId: String, deckId: String, title: String, description: String, orderIndex: Int, isUnlocked: Bool) async throws {
        let stageRef = stageCollection(userId: userId, deckId: deckId).document()
        let now = Date()

        let stage = Stage(
            id: stageRef.documentID,
            deckId: deckId,
            title: title,
            description: description,
            orderIndex: orderIndex,
            isUnlocked: isUnlocked,
            isCompleted: false,
            requiredCorrectRate: 0.7,
            bestCorrectRate: 0.0,
            lastCompletedAt: nil,
            createdAt: now,
            updatedAt: now
        )

        try stageRef.setData(from: stage)
        
        // Update deck's stageCount
        let deckRef = db.collection("users").document(userId).collection("decks").document(deckId)
        try await deckRef.updateData([
            "stageCount": FieldValue.increment(Int64(1)),
            "updatedAt": now
        ])
    }

    func updateStage(userId: String, deckId: String, stage: Stage) async throws {
        guard let stageId = stage.id else { return }
        var updatedStage = stage
        updatedStage.updatedAt = Date()

        try stageCollection(userId: userId, deckId: deckId)
            .document(stageId)
            .setData(from: updatedStage, merge: true)
    }

    func deleteStage(userId: String, deckId: String, stageId: String) async throws {
        try await stageCollection(userId: userId, deckId: deckId)
            .document(stageId)
            .delete()

        // Decrement deck's stageCount
        let deckRef = db.collection("users").document(userId).collection("decks").document(deckId)
        try await deckRef.updateData([
            "stageCount": FieldValue.increment(Int64(-1)),
            "updatedAt": Date()
        ])
    }

    func reorderStages(userId: String, deckId: String, stages: [Stage]) async throws {
        let batch = db.batch()
        let now = Date()

        for (index, stage) in stages.enumerated() {
            guard let stageId = stage.id else { continue }
            let stageRef = stageCollection(userId: userId, deckId: deckId).document(stageId)
            
            batch.updateData([
                "orderIndex": index,
                "updatedAt": now
            ], forDocument: stageRef)
        }

        try await batch.commit()
    }

    // MARK: - Discover / Public Stages (FUNGSI BARU)
    /// Mengambil data stages dari subcollection milik publicDecks di Discover
    func fetchPublicStages(deckId: String) async throws -> [Stage] {
        let snapshot = try await db.collection("publicDecks")
            .document(deckId)
            .collection("stages")
            .order(by: "orderIndex", descending: false)
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Stage.self)
        }
    }
}
