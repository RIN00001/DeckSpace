//
//  EditDeckView.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct EditDeckView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let deck: Deck
    let onSave: (Deck) async -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var category: String
    @State private var coverIconName: String
    
    @State private var isScheduled: Bool
    @State private var scheduledDays: [String]
    @State private var scheduledTime: String
    
    @State private var isSaving = false
    
    private let availableDays = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
    ]
    
    private let iconOptions = [
        "book.closed.fill",
        "swift",
        "function",
        "globe",
        "atom",
        "brain.head.profile",
        "paintpalette.fill",
        "music.note",
        "laptopcomputer",
        "graduationcap.fill"
    ]
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(deck: Deck, onSave: @escaping (Deck) async -> Void) {
        self.deck = deck
        self.onSave = onSave
        
        _title = State(initialValue: deck.title)
        _description = State(initialValue: deck.description)
        _category = State(initialValue: deck.category)
        _coverIconName = State(initialValue: deck.coverIconName ?? "book.closed.fill")
        _isScheduled = State(initialValue: deck.isScheduled)
        _scheduledDays = State(initialValue: deck.scheduledDays)
        _scheduledTime = State(initialValue: deck.scheduledTime ?? "")
    }
    
    var body: some View {
        Form {
            Section("Deck Information") {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...5)
                TextField("Category", text: $category)
            }
            
            Section("Cover Icon") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                    ForEach(iconOptions, id: \.self) { icon in
                        Button {
                            coverIconName = icon
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(coverIconName == icon ? Color.accentColor.opacity(0.18) : Color(.secondarySystemBackground))
                                    .frame(height: 54)
                                
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(coverIconName == icon ? Color.accentColor : Color.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
            }
            
            Section("Schedule") {
                Toggle("Enable Schedule", isOn: $isScheduled)
                
                if isScheduled {
                    ForEach(availableDays, id: \.self) { day in
                        Button {
                            toggleDay(day)
                        } label: {
                            HStack {
                                Text(day)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if scheduledDays.contains(day) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                    
                    TextField("Optional time, example: 19:00", text: $scheduledTime)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
        }
        .navigationTitle("Edit Deck")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await saveDeck()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!canSave || isSaving)
            }
        }
    }
    
    private func toggleDay(_ day: String) {
        if scheduledDays.contains(day) {
            scheduledDays.removeAll { $0 == day }
        } else {
            scheduledDays.append(day)
        }
    }
    
    private func saveDeck() async {
        isSaving = true
        
        var updatedDeck = deck
        updatedDeck.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDeck.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDeck.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDeck.coverIconName = coverIconName
        
        updatedDeck.isScheduled = isScheduled
        updatedDeck.scheduledDays = isScheduled ? scheduledDays : []
        
        let cleanScheduledTime = scheduledTime.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDeck.scheduledTime = isScheduled && !cleanScheduledTime.isEmpty ? cleanScheduledTime : nil
        
        await onSave(updatedDeck)
        
        isSaving = false
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditDeckView(
            deck: Deck(
                id: "deck_001",
                ownerId: "user_001",
                ownerName: "Calamity",
                title: "Statistics & Probability",
                description: "Because statistik",
                category: "Mathematics",
                coverIconName: "function",
                stageCount: 1,
                isScheduled: true,
                scheduledDays: ["Monday", "Wednesday"],
                scheduledTime: "19:00"
            )
        ) { _ in }
    }
}
