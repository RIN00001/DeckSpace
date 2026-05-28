//
//  DiscoverDeckDetailView.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct DiscoverDeckDetailView: View {
    let deck: Deck

    @StateObject private var stageViewModel = StageViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()
    
    @State private var isDownloading = false
    @State private var hasDownloaded = false
    
    // 1. Tambahkan deteksi ukuran layar
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    private var deckId: String {
        deck.id ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                deckHeader

                // Tombol aksi utama (Download)
                downloadActionButton

                stageSection

                if let errorMessage = discoverViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            .padding()
            // 2. Kunci lebar konten di iPad/Mac agar tidak melar
            .frame(maxWidth: sizeClass == .compact ? .infinity : 700)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .navigationTitle("Deck Preview")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty {
                // Mengambil daftar stage publik milik deck ini dari database
                await stageViewModel.fetchPublicStages(deckId: deckId)
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
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(deck.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }
            }

            if !deck.description.isEmpty {
                Text(deck.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("\(deck.stageCount) Stages", systemImage: "rectangle.stack.fill")
                Spacer()
                Text("Created by \(deck.ownerName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
        }
    }

    private var downloadActionButton: some View {
        Button {
            Task {
                isDownloading = true
                await discoverViewModel.downloadDeck(deck)
                
                if discoverViewModel.errorMessage == nil {
                    hasDownloaded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        dismiss()
                    }
                }
                isDownloading = false
            }
        } label: {
            HStack {
                if isDownloading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: hasDownloaded ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                    Text(hasDownloaded ? "Downloaded to Library" : "Download Deck")
                        .fontWeight(.semibold)
                }
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(hasDownloaded ? Color.green : Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isDownloading || hasDownloaded)
    }

    // Bagian list Stage yang kini sudah sangat rapi dan modular
    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Included Stages")
                .font(.title3)
                .fontWeight(.bold)
            
            if stageViewModel.stages.isEmpty {
                HStack {
                    Spacer()
                    Text("No stages info available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(stageViewModel.stages) { stage in
                        // Memanggil komponen terpisah yang baru saja kita buat
                        _DiscoverStageRowView(stage: stage)
                    }
                }
            }
        }
    }
}
