//
//  DeckDetailView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI
import FirebaseAuth

struct DeckDetailView: View {
    let deck: Deck

    @StateObject private var stageViewModel = StageViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()

    @State private var showingAddStageSheet = false
    @State private var isPublished: Bool = false
    @State private var isPublishing: Bool = false

    private var deckId: String {
        deck.id ?? ""
    }
    
    private var activeStage: Stage? {
        stageViewModel.stages.first(where: { $0.isUnlocked && !$0.isCompleted }) ?? stageViewModel.stages.first
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
                
                if let discoverError = discoverViewModel.errorMessage {
                    Text(discoverError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(deck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Sinkronkan status tombol publish berdasarkan data awal dari model deck
            isPublished = deck.isPublished
            
            if !deckId.isEmpty {
                await stageViewModel.fetchStages(deckId: deckId)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                // 1. Tombol Publish (Hanya tampil untuk pemilik Deck asli)
                if deck.ownerId == Auth.auth().currentUser?.uid {
                    if isPublished {
                        Text("Published")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                            .padding(.trailing, 4)
                    } else {
                        Button {
                            Task {
                                isPublishing = true
                                
                                // Memanggil fungsi publish melalui DiscoverViewModel
                                await discoverViewModel.publishDeck(deck)
                                
                                // Jika proses di DiscoverViewModel sukses tanpa error, ubah status UI
                                if discoverViewModel.errorMessage == nil {
                                    isPublished = true
                                }
                                
                                isPublishing = false
                            }
                        } label: {
                            if isPublishing {
                                ProgressView()
                            } else {
                                Image(systemName: "globe")
                            }
                        }
                        // Tombol di-disable jika sedang proses atau deck masih kosong (belum ada stage)
                        .disabled(isPublishing || stageViewModel.stages.isEmpty)
                    }
                }

                // 2. Tombol Tambah Stage
                Button {
                    showingAddStageSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddStageSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Stage Information")) {
                        TextField("Stage Title", text: $stageViewModel.title)
                        TextField("Description", text: $stageViewModel.description)
                    }
                }
                .navigationTitle("New Stage")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            stageViewModel.resetForm()
                            showingAddStageSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            Task {
                                await stageViewModel.createStage(deckId: deckId)
                                stageViewModel.resetForm()
                                showingAddStageSheet = false
                            }
                        }
                        .disabled(!stageViewModel.canCreateStage)
                    }
                }
            }
            .presentationDetents([.medium])
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
                        NavigationLink {
                            StageDetailView(deck: deck, stage: stage)
                        } label: {
                            // Menggunakan komponen terpisah _StageRowView.swift Anda
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
                
                // Take active stage from a deck (stages that have been done)
                if let stageToStudy = activeStage {
                    NavigationLink {
                        StudySessionView(
                            userId: Auth.auth().currentUser?.uid ?? "", deck: deck, stage: stageToStudy
                        )
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Studying (\(stageToStudy.title))")
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
