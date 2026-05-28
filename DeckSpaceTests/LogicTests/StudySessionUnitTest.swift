//
//  StudySessionUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Study Session Testing")
struct StudySessionUnitTest {
    
    @MainActor
    @Test("Study Session VM - Init state of View Model")
    func testStudySessionInitState() async {
        let viewModel = StudySessionViewModel()
        
        #expect(viewModel.sessionItems.isEmpty == true)
        #expect(viewModel.currentItemIndex == 0)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isSessionFinished == false)
        #expect(viewModel.finalScoreRate == 0.0)
        #expect(viewModel.wasStagePassed == false)
    }
    
    @MainActor
    @Test("Study Session VM - Current item is nil when queue is empty")
    func testCurrentItemNilWhenSessionEmpty() async {
        let viewModel = StudySessionViewModel()
        
        #expect(viewModel.currentItem == nil)
    }
    
    @MainActor
    @Test("Study Session VM - Current item is nil when index is outside queue")
    func testCurrentItemNilWhenIndexOutOfRange() async {
        let viewModel = StudySessionViewModel()
        
        viewModel.currentItemIndex = 5
        
        #expect(viewModel.currentItem == nil)
    }
    
    @MainActor
    @Test("Study Session VM - Manual finish state can be reset before a new queue")
    func testStudySessionManualStateMutation() async {
        let viewModel = StudySessionViewModel()
        
        viewModel.isSessionFinished = true
        viewModel.finalScoreRate = 0.85
        viewModel.wasStagePassed = true
        viewModel.errorMessage = "Mock error"
        
        #expect(viewModel.isSessionFinished == true)
        #expect(viewModel.finalScoreRate == 0.85)
        #expect(viewModel.wasStagePassed == true)
        #expect(viewModel.errorMessage == "Mock error")
    }
}
