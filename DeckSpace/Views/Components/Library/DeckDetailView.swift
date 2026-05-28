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
    @State private var editMode: EditMode = .inactive
    
    @StateObject private var stageViewModel = StageViewModel()
    @StateObject private var discoverViewModel = DiscoverViewModel()
    @StateObject private var deckViewModel = DeckViewModel()
    
    @State private var showingAddStageSheet = false
    
    init(deck: Deck) {
        self.deck = deck
        _editableDeck = State(initialValue: deck)
    }
    
    private var deckId: String {
        editableDeck.id ?? ""
    }
    
    private var isOwner: Bool {
        editableDeck.ownerId == Auth.auth().currentUser?.uid
    }
    
    private var canEditDeck: Bool {
        isOwner && !editableDeck.isPublished
    }
    
    private var sortedStages: [Stage] {
        stageViewModel.stages.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    private var activeStage: Stage? {
        if let nextStage = sortedStages.first(where: { $0.isUnlocked && !$0.isCompleted }) {
            return nextStage
        }
        
        return sortedStages.first
    }
    
    var body: some View {
        List {
            Section {
                deckHeader
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            if isOwner {
                Section {
                    publishingControlSection
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            
            Section {
                stageSectionHeader
                
                if stageViewModel.stages.isEmpty && !stageViewModel.isLoading {
                    emptyStageView
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(sortedStages) { stage in
                        NavigationLink {
                            StageDetailView(deck: editableDeck, stage: stage)
                        } label: {
                            _StageRowView(stage: stage)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowInsets(
                            EdgeInsets(
                                top: 8,
                                leading: 20,
                                bottom: 8,
                                trailing: 20
                            )
                        )
                        .contextMenu {
                            if canEditDeck {
                                Button(role: .destructive) {
                                    Task {
                                        await stageViewModel.deleteStage(
                                            deckId: deckId,
                                            stage: stage
                                        )

                                        editableDeck.stageCount = max(
                                            0,
                                            editableDeck.stageCount - 1
                                        )
                                    }
                                } label: {
                                    Label("Delete Stage", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onMove { source, destination in
                        guard canEditDeck else { return }

                        Task {
                            await stageViewModel.moveStage(
                                deckId: deckId,
                                from: source,
                                to: destination
                            )

                            await stageViewModel.fetchStages(deckId: deckId)
                        }
                    }
                    .moveDisabled(!canEditDeck)
                }
            }
            
            if let stageToStudy = activeStage {
                Section {
                    NavigationLink {
                        StudySessionView(
                            userId: Auth.auth().currentUser?.uid ?? "",
                            deck: editableDeck,
                            stage: stageToStudy
                        )
                    } label: {
                        startStudyingButtonLabel(stageToStudy)
                    }
                    .listRowSeparator(.hidden)
                }
            }
            
            errorSection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.editMode, $editMode)
        .navigationTitle(editableDeck.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !deckId.isEmpty {
                await stageViewModel.fetchStages(deckId: deckId)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if canEditDeck {
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
                    
                    Button {
                        showingAddStageSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                    Button {
                        withAnimation {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    } label: {
                        Text(editMode == .active ? "Done" : "Reorder")
                    }
                    .disabled(stageViewModel.stages.count <= 1)
                }
            }
        }
        .sheet(isPresented: $showingAddStageSheet) {
            addStageSheet
        }
    }
    
    // MARK: - Header
    
    private var deckHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 76, height: 76)
                    
                    Image(systemName: editableDeck.coverIconName ?? "book.closed.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(editableDeck.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(editableDeck.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                    
                    Text("By \(editableDeck.ownerName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if !editableDeck.description.isEmpty {
                Text(editableDeck.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            
            HStack(spacing: 12) {
                Label("\(editableDeck.stageCount) Stages", systemImage: "rectangle.stack.fill")
                
                Spacer()
                
                Label(
                    editableDeck.isPublished ? "Published" : "Private",
                    systemImage: editableDeck.isPublished ? "globe" : "lock.fill"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Publishing
    
    private var publishingControlSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Visibility")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(editableDeck.isPublished ? Color.green : Color.orange)
                            .frame(width: 9, height: 9)
                        
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
                            editableDeck = updated
                            
                            if updated.isPublished {
                                editMode = .inactive
                            }
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
                .disabled(deckViewModel.isLoading || stageViewModel.stages.isEmpty)
            }
            
            Text(
                editableDeck.isPublished
                ? "Deck is live. Unpublish it first if you want to edit, add, delete, or reorder stages."
                : "This deck is private. Publish it to share with everyone in Discover."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Stages
    
    private var stageSectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Stages")
                    .font(.title3.bold())
                
                Text(canEditDeck ? "Drag to reorder when Reorder mode is active." : "Published decks are locked from editing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if stageViewModel.isLoading {
                ProgressView()
            }
        }
        .padding(.vertical, 6)
    }
    
    private var emptyStageView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(spacing: 5) {
                Text("No stages available yet")
                    .font(.headline)
                
                Text(canEditDeck ? "Add your first stage to start building this deck." : "This deck does not have stages yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
    
    private func startStudyingButtonLabel(_ stage: Stage) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.16))
                    .frame(width: 42, height: 42)
                
                Image(systemName: "play.fill")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Start Studying")
                    .font(.headline)
                
                Text(stage.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Errors
    
    @ViewBuilder
    private var errorSection: some View {
        if stageViewModel.errorMessage != nil ||
            discoverViewModel.errorMessage != nil ||
            deckViewModel.errorMessage != nil {
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
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
            }
        }
    }
    
    // MARK: - Add Stage Sheet
    
    private var addStageSheet: some View {
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
                        stageViewModel.resetForm()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await stageViewModel.createStage(deckId: deckId)
                            showingAddStageSheet = false
                            editableDeck.stageCount += 1
                        }
                    }
                    .disabled(!stageViewModel.canCreateStage)
                }
            }
        }
        .presentationDetents([.medium])
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
                description: "Learn SwiftUI using staged flashcards.",
                category: "Programming",
                coverIconName: "swift",
                stageCount: 3,
                isPublished: false,
                originalCreatorId: "user_001",
                originalCreatorName: "Calamity",
                originalDeckId: "deck_001",
                originalDeckTitle: "SwiftUI Basics"
            )
        )
    }
}
