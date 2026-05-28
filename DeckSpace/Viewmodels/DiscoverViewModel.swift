//
//  DiscoverViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var publicDecks: [Deck] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var downloadSuccessMessage: String?
    
    private let deckService = DeckService()
    private let userService = UserService.shared
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func loadDiscoverDecks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDecks = try await deckService.fetchPublicDecks()
            if let currentUid = currentUserId {
                self.publicDecks = fetchedDecks.filter { $0.ownerId != currentUid }
            } else {
                self.publicDecks = fetchedDecks
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Mengunduh deck publik ke Library pribadi
    func downloadDeck(_ deck: Deck) async {
        guard let userId = currentUserId else {
            errorMessage = "Anda harus login untuk mengunduh deck."
            return
        }
        
        guard let deckId = deck.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Ambil nama user saat ini untuk dijadikan owner baru di library
            let userProfile = try await userService.fetchUser(userId: userId)
            
            try await deckService.downloadDeck(
                userId: userId,
                username: userProfile.username,
                publicDeckId: deckId
            )
            
            downloadSuccessMessage = "Berhasil mengunduh '\(deck.title)' ke Library Anda!"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Publish Deck ke Discover
        func publishDeck(_ deck: Deck) async {
            guard let userId = currentUserId else {
                errorMessage = "Anda harus login untuk mempublikasikan deck."
                return
            }

            isLoading = true
            errorMessage = nil

            do {
                try await deckService.publishDeck(userId: userId, deck: deck)
                
                await loadDiscoverDecks()
                
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
}
