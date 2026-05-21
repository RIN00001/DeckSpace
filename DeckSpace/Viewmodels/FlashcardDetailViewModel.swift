//
//  FlashcardDetailViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import Combine
@MainActor
final class FlashcardDetailViewModel: ObservableObject {
    @Published var answers: [Answer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let flashcardService = FlashcardService()

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func fetchAnswers(
        deckId: String,
        stageId: String,
        flashcardId: String
    ) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            answers = try await flashcardService.fetchAnswers(
                userId: userId,
                deckId: deckId,
                stageId: stageId,
                flashcardId: flashcardId
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
