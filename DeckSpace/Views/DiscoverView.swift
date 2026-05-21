//
//  DiscoverView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

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
                        HStack(alignment: .center, spacing: 12) {
                            
                            // --- BAGIAN KIRI: Info Deck ---
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.accentColor.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: deck.coverIconName ?? "book.closed.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(deck.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Shared by \(deck.ownerName)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Text(deck.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .padding(.top, 2)
                                
                                HStack {
                                    Text(deck.category)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.15))
                                        .clipShape(Capsule())
                                    
                                    if deck.isRemix {
                                        Label("Remix", systemImage: "arrow.2.squarepath")
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            Spacer()
                            
                            // --- BAGIAN KANAN: Tombol Download ---
                            Button {
                                Task {
                                    await viewModel.downloadDeck(deck)
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.accentColor)
                                    .padding(12)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            // Jika sedang loading, matikan tombol agar tidak di-spam click
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.vertical, 6)
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
