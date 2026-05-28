//
//  FlashcardDetailUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

struct FlashcardDetailUnitTest {
    
    @MainActor
    @Test("Flashcard Detail VM - nit state of View Model")
    func testFlashcardDetailVMInitialState() async {
        let viewModel = FlashcardDetailViewModel()
        
        #expect(viewModel.answers.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @MainActor
    @Test("Flashcard Detail VM - Initial Pristine Detail States Metrics")
    func testFlashcardDetailVMDummyData() async {
        let viewModel = FlashcardDetailViewModel()
        
        await viewModel.fetchAnswers(deckId: "dummy_deck_id", stageId: "dummy_stage_id", flashcardId: "dummy_card_id")
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User not logged in")
        #expect(viewModel.answers.isEmpty == true)
    }
}
