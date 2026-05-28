//
//  FlashcardUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Flashcard Detail Testing in stage details")
struct FlashcardUnitTest {
    
    @MainActor
    @Test("Flashcard VM - nit state of View Model")
    func testFlashcardDetailVMInitialState() async {
        let viewModel = FlashcardViewModel()
        
        #expect(viewModel.flashcards.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.selectedType == .intro)
        #expect(viewModel.selectedDifficulty == .easy)
        #expect(viewModel.promptText == "")
        #expect(viewModel.explanationText == "")
        #expect(viewModel.paragraphModelAnswer == "")
    }
    
    @MainActor
    @Test("Flashcard VM - Validation Lofic for Intro Card")
    func testFlashcardIntroType() async {
        let viewModel = FlashcardViewModel()
        viewModel.selectedType = .intro
        
        viewModel.explanationText = " "
        #expect(viewModel.canCreateFlashcard == false)
        
        viewModel.explanationText = "Hello World"
        #expect(viewModel.canCreateFlashcard == true)
    }
    
    @MainActor
    @Test("Flashcard VM - Validation Logic for Paragraph Card")
    func testFlashcardParagraphType() async {
        let viewModel = FlashcardViewModel()
        viewModel.selectedType = .paragraph
        
        viewModel.promptText = "Type Hello World and submit it"
        
        viewModel.paragraphModelAnswer = " "
        #expect(viewModel.canCreateFlashcard == false)
        
        viewModel.paragraphModelAnswer = "Hello World"
        #expect(viewModel.canCreateFlashcard == true)
    }
    
    @MainActor
    @Test("Flashcard VM - Clear form fields clean the input")
    func testFlashcardResetInput() async {
        let viewModel = FlashcardViewModel()
        viewModel.selectedType = .paragraph
        viewModel.selectedDifficulty = .hard
        viewModel.promptText = "Explain Actors in Swift Concurrency"
        viewModel.explanationText = "Some text..."
        viewModel.paragraphModelAnswer = "Actors protect mutable state isolation."
        
        viewModel.resetForm()
        
        #expect(viewModel.selectedType == .intro)
        #expect(viewModel.selectedDifficulty == .easy)
        #expect(viewModel.promptText == "")
        #expect(viewModel.explanationText == "")
        #expect(viewModel.paragraphModelAnswer == "")
    }
    
    @MainActor
    @Test("Flashcard VM - Fetch flashcard from a stage without")
    func testFetchFlashcardsWithoutActiveSession() async {
        let viewModel = FlashcardViewModel()
        
        await viewModel.fetchFlashcards(deckId: "mock_deck_id", stageId: "mock_stage_id")
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User is not logged in.")
        #expect(viewModel.flashcards.isEmpty == true)
    }
}
