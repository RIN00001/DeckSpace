//
//  Stage.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct Stage: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var deckId: String

    var title: String
    var description: String
    var orderIndex: Int

    var isUnlocked: Bool
    var isCompleted: Bool

    var requiredCorrectRate: Double
    var bestCorrectRate: Double
    var lastCompletedAt: Date?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String? = nil,
        deckId: String,
        title: String,
        description: String = "",
        orderIndex: Int = 0,
        isUnlocked: Bool = false,
        isCompleted: Bool = false,
        requiredCorrectRate: Double = 0.7,
        bestCorrectRate: Double = 0.0,
        lastCompletedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.deckId = deckId
        self.title = title
        self.description = description
        self.orderIndex = orderIndex
        self.isUnlocked = isUnlocked
        self.isCompleted = isCompleted
        self.requiredCorrectRate = requiredCorrectRate
        self.bestCorrectRate = bestCorrectRate
        self.lastCompletedAt = lastCompletedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
