//
//  StudySessionViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("StudySessionView Tests")
@MainActor
struct StudySessionViewTests {
    
    @Test("StudySessionView Initialization with Dummy Data")
    func testStudySessionViewInitialization() async throws {
        let now = Date()
        let dummyUserId = "user_testing_123"
        
        //Dummy Deck
        let dummyDeck = Deck(
            id: "deck_testing_123",
            ownerId: dummyUserId,
            ownerName: "Tester",
            title: "Test Deck",
            description: "Description Test",
            category: "Education",
            coverIconName: "book",
            stageCount: 1,
            currentStageId: "stage_testing_123",
            isScheduled: false,
            scheduledDays: [],
            scheduledTime: nil,
            isPublished: false,
            isDownloadedCopy: false,
            isRemix: false,
            originalCreatorId: dummyUserId,
            originalCreatorName: "Tester",
            originalDeckId: "deck_testing_123",
            originalDeckTitle: "Test Deck",
            createdAt: now,
            updatedAt: now
        )
        
        //Dummy Stage
        let dummyStage = Stage(
            id: "stage_testing_123",
            deckId: "deck_testing_123",
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
        
        //Inisialisasi View
        let _ = StudySessionView(
            userId: dummyUserId,
            deck: dummyDeck,
            stage: dummyStage
        )
    }
}
