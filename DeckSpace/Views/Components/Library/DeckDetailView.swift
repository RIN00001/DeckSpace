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
    
    @State private var editableDeck: Deck
    
    @StateObject private var stageViewModel = StageViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()
    @StateObject private var deckViewModel = DeckViewModel()

    @State private var showingAddStageSheet = false
    // isPublished dan isPublishing dihapus karena kita ambil langsung dari editableDeck & ViewModel

    init(deck: Deck) {
        self.deck = deck
        _editableDeck = State(initialValue: deck)
    }
    
    private var deckId: String {
        editableDeck.id ?? ""
    }
    
    private var activeStage: Stage? {
        let sortedStages = stageViewModel.stages.sorted { $0.orderIndex < $1.orderIndex }
      
        if let nextStage = sortedStages.first(where: { $0.isUnlocked && !$0.isCompleted }) {
            return nextStage
        }
 
        return sortedStages.first
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                deckHeader
                
                // KONTROL PUBLISH BARU DISISIPKAN DI SINI
                if editableDeck.ownerId == Auth.auth().currentUser?.uid {
                    publishingControlSection
                }
                
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
                
                if let deckError = deckViewModel.errorMessage {
                    Text(deckError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(editableDeck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty {
                await stageViewModel.fetchStages(deckId: deckId)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // TOMBOL EDIT
                NavigationLink {
                    EditDeckView(deck: editableDeck) { updatedDeck in
                        Task {
                            await deckViewModel.updateDeck(updatedDeck)
                            editableDeck = updatedDeck
                        }
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(editableDeck.isPublished) // KUNCI JIKA PUBLISHED
                
                // TOMBOL TAMBAH STAGE
                Button {
                    showingAddStageSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(editableDeck.isPublished) // KUNCI JIKA PUBLISHED
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
                            showingAddStageSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            Task {
                                await stageViewModel.createStage(deckId: deckId)
                                showingAddStageSheet = false
                                // Opsi: Tambah deck.stageCount lokal agar sinkron
                                editableDeck.stageCount += 1
                            }
                        }
                        .disabled(stageViewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Components
    
    private var deckHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 70, height: 70)

                    Image(systemName: editableDeck.coverIconName ?? "book.closed.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(editableDeck.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(editableDeck.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }
            }

            if !editableDeck.description.isEmpty {
                Text(editableDeck.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("\(editableDeck.stageCount) Stages", systemImage: "rectangle.stack.fill")
                Spacer()
                Text("By \(editableDeck.ownerName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
        }
    }
    
    // KOMPONEN PUBLISHING BARU
    private var publishingControlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visibility")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(editableDeck.isPublished ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        
                        Text(editableDeck.isPublished ? "Published to Discover" : "Private Draft")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(editableDeck.isPublished ? .green : .orange)
                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        if let updated = await deckViewModel.togglePublishStatus(for: editableDeck) {
                            editableDeck = updated // Update UI seketika
                        }
                    }
                } label: {
                    if deckViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text(editableDeck.isPublished ? "Unpublish" : "Publish Live")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(editableDeck.isPublished ? .red : .accentColor)
                .disabled(deckViewModel.isLoading || stageViewModel.stages.isEmpty) // Cegah publish deck kosong
            }
            
            Text(editableDeck.isPublished
                 ? "Deck is live. Unpublish to edit or add new stages."
                 : "This deck is private. Publish it to share with everyone.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.top, 4)
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
                            StageDetailView(deck: editableDeck, stage: stage)
                        } label: {
                            _StageRowView(stage: stage)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await stageViewModel.deleteStage(deckId: deckId, stage: stage)
                                    editableDeck.stageCount = max(0, editableDeck.stageCount - 1)
                                }
                            } label: {
                                Label("Delete Stage", systemImage: "trash")
                            }
                        }
                    }
                }
                
                if let stageToStudy = activeStage {
                    NavigationLink {
                        StudySessionView(
                            userId: Auth.auth().currentUser?.uid ?? "",
                            deck: editableDeck,
                            stage: stageToStudy
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
