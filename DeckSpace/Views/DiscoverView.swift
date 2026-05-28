//
//  DiscoverView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    // 1. Deteksi ukuran layar
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    // Konfigurasi kolom untuk tampilan iPad & Mac
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 320, maximum: .infinity), spacing: 16)]
    }
    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 2. Memanggil Helper Layout Dinamis
                    decksContentView
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
    
    // MARK: - Komponen View Terpisah
    
    @ViewBuilder
    private var decksContentView: some View {
        if sizeClass == .compact {
            // Tampilan iPhone: Menggunakan List bawaan
            List(viewModel.publicDecks) { deck in
                deckRowLink(for: deck)
            }
            .listStyle(.plain)
        } else {
            // Tampilan iPad & Mac: Menggunakan Grid dan dibatasi lebarnya
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.publicDecks) { deck in
                        deckRowLink(for: deck)
                            // Menambahkan padding sedikit agar mirip kotak kartu di Grid
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }
                }
                .padding()
                // Membatasi lebar agar tidak melar di layar ultra-wide
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
    
    // Helper untuk membungkus NavigationLink agar kode tidak berulang
    private func deckRowLink(for deck: Deck) -> some View {
        NavigationLink {
            DiscoverDeckDetailView(deck: deck)
        } label: {
            _DiscoverDeckRowView(deck: deck, viewModel: viewModel)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DiscoverView()
}
