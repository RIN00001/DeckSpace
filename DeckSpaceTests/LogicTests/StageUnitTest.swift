//
//  StageUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Stage Management Testing")
struct StageUnitTest {
    
    @MainActor
    @Test("Stage VM - Init state of View Model")
    func testStageInitState() async {
        let viewModel = StageViewModel()
        
        #expect(viewModel.stages.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.title == "")
        #expect(viewModel.description == "")
        #expect(viewModel.canCreateStage == false)
    }
    
    @MainActor
    @Test("Stage VM - Validation rejects blank and whitespace title")
    func testStageValidationEmptyTitle() async {
        let viewModel = StageViewModel()
        
        viewModel.title = ""
        #expect(viewModel.canCreateStage == false)
        
        viewModel.title = "   "
        #expect(viewModel.canCreateStage == false)
        
        viewModel.title = "\n\t"
        #expect(viewModel.canCreateStage == false)
    }
    
    @MainActor
    @Test("Stage VM - Validation accepts filled title")
    func testStageValidationSuccess() async {
        let viewModel = StageViewModel()
        
        viewModel.title = "SwiftUI Basics"
        viewModel.description = "Learn the basic concept of SwiftUI views and state."
        
        #expect(viewModel.canCreateStage == true)
    }
    
    @MainActor
    @Test("Stage VM - Reset form clears stage input")
    func testStageResetForm() async {
        let viewModel = StageViewModel()
        
        viewModel.title = "Advanced SwiftUI"
        viewModel.description = "NavigationStack, ViewModel, and reusable components."
        
        viewModel.resetForm()
        
        #expect(viewModel.title == "")
        #expect(viewModel.description == "")
        #expect(viewModel.canCreateStage == false)
    }
    
    @MainActor
    @Test("Stage VM - Fetch stages fails when user is not logged in")
    func testFetchStagesWithoutActiveAccount() async {
        let viewModel = StageViewModel()
        
        await viewModel.fetchStages(deckId: "mock_deck_id")
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User is not logged in.")
        #expect(viewModel.stages.isEmpty == true)
    }
    
    @MainActor
    @Test("Stage VM - Create stage fails when user is not logged in")
    func testCreateStageWithoutActiveAccount() async {
        let viewModel = StageViewModel()
        viewModel.title = "Stage 1"
        viewModel.description = "Mock description"
        
        await viewModel.createStage(deckId: "mock_deck_id")
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User is not logged in.")
        #expect(viewModel.stages.isEmpty == true)
    }
    
    @MainActor
    @Test("Stage VM - Reorder stages fails when user is not logged in")
    func testReorderStagesWithoutActiveAccount() async {
        let viewModel = StageViewModel()
        
        await viewModel.reorderStages(deckId: "mock_deck_id")
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User is not logged in.")
    }
}
