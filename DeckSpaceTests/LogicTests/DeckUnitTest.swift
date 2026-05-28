//
//  DeckUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Deck Management Testing")
struct DeckUnitTest {
    
    @MainActor
    @Test("Deck VM - Init state of View Model")
    func testDeckInit() async {
        let viewModel = DeckViewModel()
        
        #expect(viewModel.decks.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.title == "")
        #expect(viewModel.description == "")
        #expect(viewModel.category == "")
        #expect(viewModel.coverIconName == "book.closed.fill")
        #expect(viewModel.isScheduled == false)
        #expect(viewModel.scheduledDays.isEmpty == true)
    }
    
    @MainActor
    @Test("Deck VM - Validation input blank form fields")
    func testDeckValidationEmptyInputs() async {
        let viewModel = DeckViewModel()
        
        #expect(viewModel.canCreateDeck == false)
        
        // Only input title with no description
        viewModel.title = "Aviation Quiz"
        #expect(viewModel.canCreateDeck == false)
        
        // Only input description without title
        viewModel.description = "Learn about aviation in under 30 minuts"
        #expect(viewModel.canCreateDeck == false)
    }
    
    @MainActor
    @Test("Deck VM - Validation success when form is all filled")
    func testDeckSuccessCreated() async {
        let viewModel = DeckViewModel()
        
        viewModel.title = "Boeing History"
        viewModel.description = "History about Boeing from first day to today"
        viewModel.category = "General"
        
        #expect(viewModel.canCreateDeck == true)
    }
    
    @MainActor
    @Test("Deck VM - Toggle Scheduled Day Tracking for Home View")
    func testDeckToggleBasedOnDay() async {
        let viewModel = DeckViewModel()
        
        // Add a day parameter when missing from the collection
        viewModel.toggleScheduledDay("Monday")
        #expect(viewModel.scheduledDays.count == 1)
        #expect(viewModel.scheduledDays.contains("Monday") == true)
        
        // Add an extra unique tracking indicator element
        viewModel.toggleScheduledDay("Thursday")
        #expect(viewModel.scheduledDays.count == 2)
        
        // Toggle the identical tracking day a second time to handle array cleaning
        viewModel.toggleScheduledDay("Monday")
        #expect(viewModel.scheduledDays.count == 1)
        #expect(viewModel.scheduledDays.contains("Monday") == false)
    }
    
    @MainActor
    @Test("Deck VM - Reset state back to empty form")
    func testDeckResetForm() async {
        let viewModel = DeckViewModel()
        
        // Input form mocks
        viewModel.title = "Advance Aviation Quiz"
        viewModel.description = "About planes that flies throughout the history"
        viewModel.category = "General"
        viewModel.coverIconName = "globe"
        viewModel.isScheduled = true
        viewModel.scheduledDays = ["Wednesday", "Saturday"]
        
        // Reset the forms into a clean state
        viewModel.resetCreateForm()
        
        // The tests
        #expect(viewModel.title == "")
        #expect(viewModel.description == "")
        #expect(viewModel.category == "")
        #expect(viewModel.coverIconName == "book.closed.fill")
        #expect(viewModel.isScheduled == false)
        #expect(viewModel.scheduledDays.isEmpty == true)
    }
    
    @MainActor
    @Test("Deck VM - Fetch deck but failedwhen user is not logged")
    func testDeckFetchWithoutActiveAccount() async {
        let viewModel = DeckViewModel()
        
        await viewModel.fetchDecks()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "User is not logged in.")
        #expect(viewModel.decks.isEmpty == true)
    }
}
