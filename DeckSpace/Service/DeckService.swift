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

    // MARK: - Collection References
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
    
    private var publicDeckCollection: CollectionReference {
        db.collection("publicDecks")
    }

    // MARK: - User Personal Decks
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
            createdAt: now,
            updatedAt: now
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
    
    // MARK: - Discover & Public Decks Feature
    
    /// Mengambil semua deck yang dipublish oleh user lain di halaman Discover
    func fetchPublicDecks() async throws -> [Deck] {
        let snapshot = try await publicDeckCollection
            .order(by: "publishedAt", descending: true)
            .getDocuments()
            
        return try snapshot.documents.compactMap { document in
            try document.data(as: Deck.self)
        }
    }
    
    /// Memublikasikan deck beserta ISINYA (Stages & Flashcards) ke area Discover
    func publishDeck(userId: String, deck: Deck) async throws {
        guard let deckId = deck.id else {
            throw DeckServiceError.missingDeckId
        }
        let now = Date()
        
        var publishedDeck = deck
        publishedDeck.isPublished = true
        publishedDeck.publishedAt = now
        publishedDeck.updatedAt = now
        
        let publicDeckRef = publicDeckCollection.document(deckId)
        
        // 1. Simpan dokumen utama ke 'publicDecks'
        try publicDeckRef.setData(from: publishedDeck)
        
        // 2. Salin Subcollection: Stages
        let userDeckRef = userDeckCollection(userId: userId).document(deckId)
        let stagesSnapshot = try await userDeckRef.collection("stages").getDocuments()
        
        for stageDoc in stagesSnapshot.documents {
            let stage = try stageDoc.data(as: Stage.self)
            let publicStageRef = publicDeckRef.collection("stages").document(stageDoc.documentID)
            try publicStageRef.setData(from: stage)
            
            // 3. Salin Subcollection: Flashcards
            let flashcardsSnapshot = try await stageDoc.reference.collection("flashcards").getDocuments()
            for flashcardDoc in flashcardsSnapshot.documents {
                let flashcard = try flashcardDoc.data(as: Flashcard.self)
                let publicFlashcardRef = publicStageRef.collection("flashcards").document(flashcardDoc.documentID)
                try publicFlashcardRef.setData(from: flashcard)
                
                // 4. Salin Subcollection: Answers
                let answersSnapshot = try await flashcardDoc.reference.collection("answers").getDocuments()
                for answerDoc in answersSnapshot.documents {
                    let answer = try answerDoc.data(as: Answer.self)
                    let publicAnswerRef = publicFlashcardRef.collection("answers").document(answerDoc.documentID)
                    try publicAnswerRef.setData(from: answer)
                }
            }
        }
        
        // 5. Perbarui status 'isPublished' di library pribadi user
        try await userDeckRef.updateData([
            "isPublished": true,
            "publishedAt": now,
            "updatedAt": now
        ])
    }
    
    /// Mengunduh deck publik beserta ISINYA (Stages & Flashcards) ke Library pribadi
    func downloadDeck(userId: String, username: String, publicDeckId: String) async throws {
        let publicDeckRef = publicDeckCollection.document(publicDeckId)
        let publicDeck = try await publicDeckRef.getDocument(as: Deck.self)
        
        let now = Date()
        // Buat ID unik baru di library user
        let newUserDeckRef = userDeckCollection(userId: userId).document()
        
        var downloadedDeck = publicDeck
        downloadedDeck.id = newUserDeckRef.documentID
        downloadedDeck.ownerId = userId
        downloadedDeck.ownerName = username
        downloadedDeck.isPublished = false
        downloadedDeck.isDownloadedCopy = true
        downloadedDeck.createdAt = now
        downloadedDeck.updatedAt = now
        downloadedDeck.publishedAt = nil
        
        // Data Tracking (Silsilah Remix)
        if publicDeck.isRemix {
            // Jika deck aslinya adalah remix, pertahankan originalCreator-nya
            downloadedDeck.sourceOwnerId = publicDeck.ownerId
            downloadedDeck.sourceOwnerName = publicDeck.ownerName
            downloadedDeck.sourceDeckId = publicDeckId
            downloadedDeck.sourceDeckTitle = publicDeck.title
        } else {
            // Jika ini pertama kali di-download dari pembuat asli
            downloadedDeck.originalCreatorId = publicDeck.ownerId
            downloadedDeck.originalCreatorName = publicDeck.ownerName
            downloadedDeck.originalDeckId = publicDeckId
            downloadedDeck.originalDeckTitle = publicDeck.title
            
            downloadedDeck.sourceOwnerId = publicDeck.ownerId
            downloadedDeck.sourceOwnerName = publicDeck.ownerName
            downloadedDeck.sourceDeckId = publicDeckId
            downloadedDeck.sourceDeckTitle = publicDeck.title
        }
        
        // 1. Simpan dokumen utama ke library user
        try newUserDeckRef.setData(from: downloadedDeck)
        
        // 2. Salin Subcollection: Stages
        let stagesSnapshot = try await publicDeckRef.collection("stages").getDocuments()
        for stageDoc in stagesSnapshot.documents {
            var stage = try stageDoc.data(as: Stage.self)
            stage.deckId = newUserDeckRef.documentID // Ubah ID induknya
            
            // Reset Progress Belajar untuk user baru
            stage.isUnlocked = (stage.orderIndex == 0)
            stage.isCompleted = false
            stage.bestCorrectRate = 0.0
            
            let userStageRef = newUserDeckRef.collection("stages").document(stageDoc.documentID)
            try userStageRef.setData(from: stage)
            
            // 3. Salin Subcollection: Flashcards
            let flashcardsSnapshot = try await stageDoc.reference.collection("flashcards").getDocuments()
            for flashcardDoc in flashcardsSnapshot.documents {
                var flashcard = try flashcardDoc.data(as: Flashcard.self)
                flashcard.deckId = newUserDeckRef.documentID
                flashcard.stageId = userStageRef.documentID
                
                // Reset Skor dan Statistik Review
                flashcard.masteryScore = 0
                flashcard.isMastered = false
                flashcard.correctCount = 0
                flashcard.incorrectCount = 0
                flashcard.correctStreak = 0
                flashcard.lastReviewedAt = nil
                
                let userFlashcardRef = userStageRef.collection("flashcards").document(flashcardDoc.documentID)
                try userFlashcardRef.setData(from: flashcard)
                
                // 4. Salin Subcollection: Answers
                let answersSnapshot = try await flashcardDoc.reference.collection("answers").getDocuments()
                for answerDoc in answersSnapshot.documents {
                    var answer = try answerDoc.data(as: Answer.self)
                    answer.flashcardId = userFlashcardRef.documentID
                    
                    let userAnswerRef = userFlashcardRef.collection("answers").document(answerDoc.documentID)
                    try userAnswerRef.setData(from: answer)
                }
            }
        }
        
        // 5. Tambah counter download di Discover publik (sebagai bentuk apresiasi)
        try await publicDeckRef.updateData([
            "downloadCount": FieldValue.increment(Int64(1))
        ])
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
