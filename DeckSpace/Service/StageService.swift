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

    private func deckDocument(userId: String, deckId: String) -> DocumentReference {
        db.collection("users")
            .document(userId)
            .collection("decks")
            .document(deckId)
    }

    private func stageCollection(userId: String, deckId: String) -> CollectionReference {
        deckDocument(userId: userId, deckId: deckId)
            .collection("stages")
    }

    func fetchStages(userId: String, deckId: String) async throws -> [Stage] {
        let snapshot = try await stageCollection(userId: userId, deckId: deckId)
            .order(by: "orderIndex")
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: Stage.self)
        }
    }

    func createStage(
        userId: String,
        deckId: String,
        title: String,
        description: String,
        orderIndex: Int,
        isUnlocked: Bool
    ) async throws {
        let now = Date()
        let stageRef = stageCollection(userId: userId, deckId: deckId).document()

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

        try await deckDocument(userId: userId, deckId: deckId).updateData([
            "stageCount": FieldValue.increment(Int64(1)),
            "updatedAt": now
        ])
    }

    func updateStage(
        userId: String,
        deckId: String,
        stage: Stage
    ) async throws {
        guard let stageId = stage.id else {
            throw StageServiceError.missingStageId
        }

        var updatedStage = stage
        updatedStage.updatedAt = Date()

        try stageCollection(userId: userId, deckId: deckId)
            .document(stageId)
            .setData(from: updatedStage, merge: true)

        try await deckDocument(userId: userId, deckId: deckId).updateData([
            "updatedAt": Date()
        ])
    }

    func deleteStage(
        userId: String,
        deckId: String,
        stageId: String
    ) async throws {
        try await stageCollection(userId: userId, deckId: deckId)
            .document(stageId)
            .delete()

        try await deckDocument(userId: userId, deckId: deckId).updateData([
            "stageCount": FieldValue.increment(Int64(-1)),
            "updatedAt": Date()
        ])
    }

    func reorderStages(
        userId: String,
        deckId: String,
        stages: [Stage]
    ) async throws {
        let batch = db.batch()
        let now = Date()

        for (index, stage) in stages.enumerated() {
            guard let stageId = stage.id else { continue }

            let ref = stageCollection(userId: userId, deckId: deckId)
                .document(stageId)

            batch.updateData([
                "orderIndex": index,
                "updatedAt": now
            ], forDocument: ref)
        }

        batch.updateData([
            "updatedAt": now
        ], forDocument: deckDocument(userId: userId, deckId: deckId))

        try await batch.commit()
    }
}

enum StageServiceError: LocalizedError {
    case missingStageId

    var errorDescription: String? {
        switch self {
        case .missingStageId:
            return "Stage ID is missing."
        }
    }
}
