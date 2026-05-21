//
//  Flashcard.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct Flashcard: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var deckId: String
    var stageId: String

    var type: FlashcardType
    var orderIndex: Int
    var difficultyLevel: DifficultyLevel

    var promptText: String?
    var explanationText: String?

    // Firebase Storage is skipped for prototype.
    // Keep imageUrl for future compatibility.
    var imageUrl: String?
    var imageIconName: String?

    var masteryScore: Int
    var masteryThreshold: Int
    var isMastered: Bool

    var correctCount: Int
    var incorrectCount: Int
    var correctStreak: Int
    var lastReviewedAt: Date?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String? = nil,
        deckId: String,
        stageId: String,
        type: FlashcardType,
        orderIndex: Int = 0,
        difficultyLevel: DifficultyLevel = .easy,
        promptText: String? = nil,
        explanationText: String? = nil,
        imageUrl: String? = nil,
        imageIconName: String? = nil,
        masteryScore: Int = 0,
        masteryThreshold: Int = 8,
        isMastered: Bool = false,
        correctCount: Int = 0,
        incorrectCount: Int = 0,
        correctStreak: Int = 0,
        lastReviewedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.deckId = deckId
        self.stageId = stageId
        self.type = type
        self.orderIndex = orderIndex
        self.difficultyLevel = difficultyLevel
        self.promptText = promptText
        self.explanationText = explanationText
        self.imageUrl = imageUrl
        self.imageIconName = imageIconName
        self.masteryScore = masteryScore
        self.masteryThreshold = masteryThreshold
        self.isMastered = isMastered
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.correctStreak = correctStreak
        self.lastReviewedAt = lastReviewedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var priorityScore: Int {
        let difficultyWeight = difficultyLevel.initialPriorityWeight
        return difficultyWeight + (incorrectCount * 2) - correctCount - masteryScore
    }

    var isScored: Bool {
        type.isScored
    }
}
