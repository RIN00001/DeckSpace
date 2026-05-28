//
//  DiscoverView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.publicDecks.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Fetching public decks...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                        Text(errorMessage)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await viewModel.loadDiscoverDecks() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.publicDecks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        
                        Text("Discover Space")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Public decks from other creators will appear here later.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(viewModel.publicDecks) { deck in
                        // Routing aman ke halaman pratinjau detail deck
                        NavigationLink {
                            DiscoverDeckDetailView(deck: deck)
                        } label: {
                            // Memanggil komponen yang sudah dipisah ke file _DiscoverDeckRowView.swift
                            _DiscoverDeckRowView(deck: deck, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Discover")
            .refreshable {
                await viewModel.loadDiscoverDecks()
            }
            .task {
                await viewModel.loadDiscoverDecks()
            }
            // --- ALERT SUKSES DOWNLOAD ---
            .alert("Success", isPresented: Binding(
                get: { viewModel.downloadSuccessMessage != nil },
                set: { _ in viewModel.downloadSuccessMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                if let msg = viewModel.downloadSuccessMessage {
                    Text(msg)
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
}
