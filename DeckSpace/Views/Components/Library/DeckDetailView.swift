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
    @State private var isPublished: Bool = false
    @State private var isPublishing: Bool = false

    init(deck: Deck) {
        self.deck = deck
        _editableDeck = State(initialValue: deck)
    }
    
    private var deckId: String {
        editableDeck.id ?? ""
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
            isPublished = editableDeck.isPublished
            
            if !deckId.isEmpty {
                await stageViewModel.fetchStages(deckId: deckId)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    EditDeckView(deck: editableDeck) { updatedDeck in
                        await deckViewModel.updateDeck(updatedDeck)
                        editableDeck = updatedDeck
                        isPublished = updatedDeck.isPublished
                    }
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                if editableDeck.ownerId == Auth.auth().currentUser?.uid {
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
                                
                                await discoverViewModel.publishDeck(editableDeck)
                                
                                if discoverViewModel.errorMessage == nil {
                                    isPublished = true
                                    editableDeck.isPublished = true
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
                        .disabled(isPublishing || stageViewModel.stages.isEmpty)
                    }
                }

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
                            showingAddStageSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            Task {
                                await stageViewModel.createStage(deckId: deckId)
                                showingAddStageSheet = false
                            }
                        }
                        .disabled(stageViewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
