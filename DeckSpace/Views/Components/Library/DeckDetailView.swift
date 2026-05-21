//
//  DeckDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct DeckDetailView: View {
    let deck: Deck

    @StateObject private var stageViewModel = StageViewModel()

    private var deckId: String {
        deck.id ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                deckHeader

                stageSection

                if let errorMessage = stageViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty {
                await stageViewModel.fetchStages(deckId: deckId)
            }
        }
    }

    private var deckHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 70, height: 70)

                    Image(systemName: deck.coverIconName ?? "book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(deck.title)
                        .font(.title2.bold())

                    Text(deck.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(deck.description)
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Label("\(deck.stageCount) stage", systemImage: "square.stack.3d.up.fill")

                if deck.isScheduled {
                    Label("Scheduled", systemImage: "calendar")
                }

                if deck.isPublished {
                    Label("Published", systemImage: "globe")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
        )
    }

    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Stages")
                    .font(.title3.bold())

                Spacer()

                if stageViewModel.isLoading {
                    ProgressView()
                }
            }

            _StageFormView(
                viewModel: stageViewModel,
                deckId: deckId
            )

            if stageViewModel.stages.isEmpty && !stageViewModel.isLoading {
                Text("No stage found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(stageViewModel.stages) { stage in
                        NavigationLink {
                            StageDetailView(deck: deck, stage: stage)
                        } label: {
                            _StageRowView(stage: stage)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await stageViewModel.deleteStage(deckId: deckId, stage: stage)
                                }
                            } label: {
                                Label("Delete Stage", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeckDetailView(
            deck: Deck(
                id: "deck_001",
                ownerId: "user_001",
                ownerName: "Calamity",
                title: "SwiftUI Basics",
                description: "Learn basic SwiftUI concepts using staged flashcards.",
                category: "Programming",
                coverIconName: "swift",
                stageCount: 1,
                isScheduled: true,
                scheduledDays: ["Monday"],
                scheduledTime: "19:00",
                originalCreatorId: "user_001",
                originalCreatorName: "Calamity",
                originalDeckId: "deck_001",
                originalDeckTitle: "SwiftUI Basics"
            )
        )
    }
}
