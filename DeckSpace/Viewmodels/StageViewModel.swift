//
//  StageViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class StageViewModel: ObservableObject {
    @Published var stages: [Stage] = []

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var title = ""
    @Published var description = ""

    private let stageService = StageService()

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var canCreateStage: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func fetchStages(deckId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            stages = try await stageService.fetchStages(userId: userId, deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createStage(deckId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard canCreateStage else {
            errorMessage = "Please enter a stage title."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let orderIndex = stages.count
            let shouldUnlock = stages.isEmpty

            try await stageService.createStage(
                userId: userId,
                deckId: deckId,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                orderIndex: orderIndex,
                isUnlocked: shouldUnlock
            )

            resetForm()
            await fetchStages(deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateStage(deckId: String, stage: Stage) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await stageService.updateStage(
                userId: userId,
                deckId: deckId,
                stage: stage
            )

            await fetchStages(deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteStage(deckId: String, stage: Stage) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        guard let stageId = stage.id else {
            errorMessage = "Stage ID is missing."
            return
        }

        if stages.count <= 1 {
            errorMessage = "A deck must have at least one stage."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await stageService.deleteStage(
                userId: userId,
                deckId: deckId,
                stageId: stageId
            )

            stages.removeAll { $0.id == stageId }
            await reorderStages(deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func moveStage(deckId: String, from source: IndexSet, to destination: Int) async {
        let movingStages = source.map { stages[$0] }

        for index in source.sorted(by: >) {
            stages.remove(at: index)
        }

        let removedBeforeDestination = source.filter { $0 < destination }.count
        let adjustedDestination = max(0, min(destination - removedBeforeDestination, stages.count))

        stages.insert(contentsOf: movingStages, at: adjustedDestination)

        await reorderStages(deckId: deckId)
    }

    func reorderStages(deckId: String) async {
        guard let userId = currentUserId else {
            errorMessage = "User is not logged in."
            return
        }

        do {
            try await stageService.reorderStages(
                userId: userId,
                deckId: deckId,
                stages: stages
            )

            await fetchStages(deckId: deckId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        title = ""
        description = ""
    }
}
