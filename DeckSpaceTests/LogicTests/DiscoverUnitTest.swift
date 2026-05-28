//
//  DiscoverUnitTest.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Discover Testing for downloading decks from other people")
struct DiscoverUnitTest {
    
    let dummyPublicDeck = Deck(
        id: "pub_deck_999",
        ownerId: "Community Swift Patterns",
        ownerName: "James Cullingham",
        title: "Shared open source collection layouts",
        description: "Programming",
        category: "user_123"
    )
    
    @MainActor
    @Test("Discover VM - Init state of View Model")
    func testDiscoverInitState() async {
        let viewModel = DiscoverViewModel()
        
        #expect(viewModel.publicDecks.isEmpty == true)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.downloadSuccessMessage == nil)
    }
    
    @MainActor
    @Test("Discover VM - Download deck failed because the downloader is not authenticated")
    func testDiscoverFailedToDownloadDecks() async {
        let viewModel = DiscoverViewModel()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Anda harus login untuk mengunduh deck.")
        #expect(viewModel.downloadSuccessMessage == nil)
    }
    
    @MainActor
    @Test("Discover VM - Publish deck failed because user is not authenticated")
    func testDiscoverPublishDeckFailer() async {
        let viewModel = DiscoverViewModel()
        
        await viewModel.publishDeck(dummyPublicDeck)
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Anda harus login untuk mempublikasikan deck.")
    }
    
    @MainActor
    @Test("Discover VM - Fetch marketplace handles")
    func testDiscoverLoadDecks() async {
        let viewModel = DiscoverViewModel()
        await viewModel.loadDiscoverDecks()
        #expect(viewModel.isLoading == false)
    }
}
