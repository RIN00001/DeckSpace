//
//  _DiscoverDeckRowView.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct _DiscoverDeckRowView: View {
    let deck: Deck
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
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
            
            // --- BAGIAN KANAN: Tombol Download Cepat ---
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
            .buttonStyle(.borderless)
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, 6)
    }
}
