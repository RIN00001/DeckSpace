//
//  LibraryView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var deckViewModel = DeckViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if deckViewModel.isLoading && deckViewModel.decks.isEmpty {
                    loadingView
                } else if deckViewModel.decks.isEmpty {
                    emptyStateView
                } else {
                    deckListView
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await deckViewModel.fetchDecks()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await deckViewModel.fetchDecks()
            }
        }
    }

    private var deckListView: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(deckViewModel.decks) { deck in
                    _DeckCardView(deck: deck)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await deckViewModel.deleteDeck(deck)
                                }
                            } label: {
                                Label("Delete Deck", systemImage: "trash")
                            }
                        }
                }

                if let errorMessage = deckViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading your decks...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)

            Text("No Deck Yet")
                .font(.title3.bold())

            Text("Create your first deck, then it will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let errorMessage = deckViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    LibraryView()
}
