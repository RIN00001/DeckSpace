//
//  StudySessionService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

final class StudySessionService {
    static let shared = StudySessionService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Fetch all flashcards in a specific deck for the study session
    func fetchFlashcards(userId: String, deckId: String, stageId: String) async throws -> [Flashcard] {
        let snapshot = try await db.collection("users").document(userId).collection("decks").document(deckId).collection("stages").document(stageId).collection("flashcards").order(by: "orderIndex").getDocuments()
        
        return snapshot.documents.compactMap{ try? $0.data(as: Flashcard.self) }
    }
    
    // Fetch all answer of a specific flashcard
    func fetchAnswerForCard(userId: String, deckId: String, stageId: String, cardId: String) async throws -> [Answer] {
        
        let snapshot = try await db.collection("users").document(userId).collection("decks").document(deckId).collection("stages").document(stageId).collection("flashcards").document(cardId).collection("answers").getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Answer.self) }
    }
    
    // Saves session stats & updates best score based on a stage it done
    func updateStageProgress(userId: String, deckId: String, stageId: String, isCompleted: Bool, scoreRate: Double) async throws {
        let stageRef = db.collection("users").document(userId).collection("decks").document(deckId).collection("stages").document(stageId)
        
        // Update best score of a stage
        let document = try await stageRef.getDocument()
        let currentBest = document.data()?["bestCorrectRate"] as? Double ?? 0.0
        let newBest = max(currentBest, scoreRate)
        
        var updateData: [String: Any] = [
            "bestCorrectRate": newBest,
            "lastCompletedAt": FieldValue.serverTimestamp()
        ]
        
        if isCompleted {
            updateData["isCompleted"] = true
        }
        
        try await stageRef.updateData(updateData)
    }
    
    // Fetch and unlock next stage that's locked (in sequence)
    func unlockNextStage(userId: String, deckId: String, currentStageOrderIndex: Int) async throws {
        let stageCollection = db.collection("users").document(userId).collection("decks").document(deckId).collection("stages")
        
        let snapshot = try await stageCollection.whereField("orderIndex", isGreaterThan: currentStageOrderIndex).order(by: "orderIndex").limit(to: 1)
            .getDocuments()
        
        if let nextStageDoc = snapshot.documents.first {
            try await nextStageDoc.reference.updateData(["isUnlocked": true])
            
            try await db.collection("users").document(userId).collection("decks").document(deckId).updateData(["currentStageId": nextStageDoc.documentID])
        }
    }
}
