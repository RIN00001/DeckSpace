//
//  StudySessionViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class StudySessionViewModel: ObservableObject {
    // General variable in study session
    @Published var sessionItems: [SessionItem] = []
    @Published var currentItemIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Summary for end of stage
    @Published var isSessionFinished: Bool = false
    @Published var finalScoreRate: Double = 0.0
    @Published var wasStagePassed: Bool = false
    
    // flashcards: for the amount of card shown
    private var totalQuestionCount: Int = 0
    private var correctAnswerCount: Int = 0
    
    private let service = StudySessionService.shared
    
    var currentItem: SessionItem? {
        guard currentItemIndex < sessionItems.count else { return nil }
        return sessionItems[currentItemIndex]
    }
    
    func buildSessionQUeue(userId: String, deckId: String, stageId: String) async {
        guard sessionItems.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let rawCards = try await service.fetchFlashcards(userId: userId, deckId: deckId, stageId: stageId)
            
            var generatedItems: [SessionItem] = []
            for card in rawCards {
                guard let cardId = card.id else { continue }
                
                // Fetch dynamic array of answers
                let fetchedAnswers = try await service.fetchAnswerForCard(userId: userId, deckId: deckId, stageId: stageId, cardId: cardId)
                
                // Shuffle options dynamically for better learning variability
                let shuffledChoices = fetchedAnswers.shuffled()
                
                generatedItems.append(SessionItem(flashcard: card, dynamicChoices: shuffledChoices))
            }
            
            self.sessionItems = generatedItems
            self.totalQuestionCount = generatedItems.count
            self.currentItemIndex = 0
            self.correctAnswerCount = 0
            self.isSessionFinished = false
            
        } catch {
            self.errorMessage = "Failed to assemble study items: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func evaluaeAnswer(selectedAnswer: Answer, userId: String, deckId: String, stage: Stage) async {
        // If correct, add 1
        if selectedAnswer.isCorrect {
            correctAnswerCount += 1
        }
        
        if currentItemIndex + 1 < sessionItems.count {
            currentItemIndex += 1
        } else {
            await finalizeStageSession(userId: userId, deckId: deckId, stage: stage)
        }
    }
    
    private func finalizeStageSession(userId: String, deckId: String, stage: Stage) async {
        guard totalQuestionCount > 0 else { return }
        guard let stageId = stage.id else { return }
        
        let calculatedRate = Double(correctAnswerCount) / Double(totalQuestionCount)
        self.finalScoreRate = calculatedRate
        
        // Score boundary check (Pass >= 70%)
        let minimumPassingThreshold = 0.70
        self.wasStagePassed = calculatedRate >= minimumPassingThreshold
        
        do {
            // Save attempt historical records to Firestore
            try await service.updateStageProgress(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                isCompleted: wasStagePassed,
                scoreRate: calculatedRate
            )
            
            // Auto-unlock next stage if pass (score over or equal 70)
            if wasStagePassed {
                let remainingSnapshot = try await Firestore.firestore()
                    .collection("users").document(userId)
                    .collection("decks").document(deckId)
                    .collection("stages")
                    .whereField("orderIndex", isGreaterThan: stage.orderIndex)
                    .getDocuments()
                
                if remainingSnapshot.documents.isEmpty {
                    try await service.resetDeckProgressionForReplay(userId: userId, deckId: deckId)
                } else {
                    try await service.unlockNextStage(userId: userId, deckId: deckId, currentStageOrderIndex: stage.orderIndex)
                }
            }
            
            self.isSessionFinished = true
        } catch {
            self.errorMessage = "Failed to save trial data: \(error.localizedDescription)"
        }
    }
}
