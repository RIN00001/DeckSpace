//
//  LibraryView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var deckViewModel = DeckViewModel()
    
    private let maxContentWidth: CGFloat = 1100
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let isWideLayout = proxy.size.width >= 760
                
                Group {
                    if deckViewModel.isLoading && deckViewModel.decks.isEmpty {
                        loadingView
                    } else if deckViewModel.decks.isEmpty {
                        emptyStateView
                    } else {
                        deckContentView(isWideLayout: isWideLayout)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    private func deckContentView(isWideLayout: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                libraryHeader
                
                if isWideLayout {
                    deckGridView
                } else {
                    deckListView
                }
                
                errorMessageView
            }
            .padding(.horizontal, isWideLayout ? 32 : 16)
            .padding(.vertical, 20)
            .frame(maxWidth: maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var libraryHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Decks")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Manage, edit, and continue building your flashcard decks.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var deckListView: some View {
        LazyVStack(spacing: 14) {
            ForEach(deckViewModel.decks) { deck in
                deckNavigationCard(deck)
            }
        }
    }
    
    private var deckGridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 320, maximum: 420), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(deckViewModel.decks) { deck in
                deckNavigationCard(deck)
            }
        }
    }
    
    private func deckNavigationCard(_ deck: Deck) -> some View {
        NavigationLink {
            DeckDetailView(deck: deck)
        } label: {
            _DeckCardView(deck: deck)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
    
    @ViewBuilder
    private var errorMessageView: some View {
        if let errorMessage = deckViewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            
            Text("Loading your decks...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 86, height: 86)
                
                Image(systemName: "tray")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(spacing: 6) {
                Text("No Deck Yet")
                    .font(.title3.bold())
                
                Text("Create your first deck, then it will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let errorMessage = deckViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LibraryView()
}
