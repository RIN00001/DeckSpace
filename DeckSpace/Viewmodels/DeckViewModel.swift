//
//  DeckViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import Combine


@MainActor
final class DeckViewModel: ObservableObject {
    @Published var decks: [Deck] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    // Create Deck form states
    @Published var title = ""
    @Published var description = ""
    @Published var category = ""
    @Published var coverIconName = "book.closed.fill"

    @Published var isScheduled = false
    @Published var scheduledDays: [String] = []
    @Published var scheduledTime = ""

    private let deckService = DeckService()
    private let userService = UserService.shared
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var canCreateDeck: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func fetchDecks() async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            decks = try await deckService.fetchDecks(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createDeck() async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard canCreateDeck else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await userService.fetchUser(userId: userId)
            let ownerName = user.username

            let finalScheduledTime = scheduledTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : scheduledTime.trimmingCharacters(in: .whitespacesAndNewlines)

            try await deckService.createDeck(
                ownerId: userId,
                ownerName: ownerName,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.trimmingCharacters(in: .whitespacesAndNewlines),
                coverIconName: coverIconName,
                isScheduled: isScheduled,
                scheduledDays: isScheduled ? scheduledDays : [],
                scheduledTime: isScheduled ? finalScheduledTime : nil
            )

            resetCreateForm()
            await fetchDecks()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateDeck(_ deck: Deck) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await deckService.updateDeck(userId: userId, deck: deck)
            await fetchDecks()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteDeck(_ deck: Deck) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard let deckId = deck.id else {
            errorMessage = "Deck ID is missing."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await deckService.deleteDeck(userId: userId, deckId: deckId)
            decks.removeAll { $0.id == deckId }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleScheduledDay(_ day: String) {
        if scheduledDays.contains(day) {
            scheduledDays.removeAll { $0 == day }
        } else {
            scheduledDays.append(day)
        }
    }

    func resetCreateForm() {
        title = ""
        description = ""
        category = ""
        coverIconName = "book.closed.fill"
        isScheduled = false
        scheduledDays = []
        scheduledTime = ""
    }
}
