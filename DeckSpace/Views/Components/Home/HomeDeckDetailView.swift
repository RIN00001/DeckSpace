//
//  HomeDeckDetailView.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct HomeDeckDetailView: View {
    let deck: Deck

    @StateObject private var stageViewModel = StageViewModel()
    
    // 1. Tambahkan deteksi ukuran layar (Compact vs Regular)
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var deckId: String {
        deck.id ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                deckHeader

                startSessionButton

                stageSection

                if let errorMessage = stageViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            // 2. Kunci lebar konten di iPad/Mac agar tetap proporsional di tengah
            .frame(maxWidth: sizeClass == .compact ? .infinity : 700)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty {
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
                Text("By \(deck.ownerName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
        }
    }

    private var startSessionButton: some View {
        Button {
            // TODO: Aksi untuk memicu sesi belajar flashcard
            print("Mulai sesi belajar untuk deck: \(deck.title)")
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Session")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(stageViewModel.stages.isEmpty ? Color.gray : Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(stageViewModel.stages.isEmpty)
    }

    private var stageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Stages")
                .font(.title3)
                .fontWeight(.bold)
            
            if stageViewModel.stages.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No stages available yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(stageViewModel.stages) { stage in
                        _HomeStageRowView(stage: stage)
                    }
                }
            }
        }
    }
}
