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
    
    private let maxContentWidth: CGFloat = 1100
    
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
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 820
            
            ScrollView {
                Group {
                    if isWideLayout {
                        HStack(alignment: .top, spacing: 28) {
                            previewCard
                                .frame(maxWidth: 360)
                            
                            editForm
                                .frame(maxWidth: 620)
                        }
                    } else {
                        VStack(spacing: 20) {
                            previewCard
                            
                            editForm
                        }
                    }
                }
                .padding(.horizontal, isWideLayout ? 32 : 16)
                .padding(.vertical, 24)
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
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
    
    // MARK: - Preview
    
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 76, height: 76)
                    
                    Image(systemName: coverIconName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(cleanTitle.isEmpty ? "Deck Title" : cleanTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    Text(cleanCategory.isEmpty ? "Category" : cleanCategory)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            Text(cleanDescription.isEmpty ? "Deck description will appear here." : cleanDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Label("\(deck.stageCount) Stages", systemImage: "rectangle.stack.fill")
                
                Label(
                    isScheduled ? scheduleSummary : "No schedule enabled",
                    systemImage: isScheduled ? "calendar.badge.clock" : "calendar"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }
    
    private var scheduleSummary: String {
        if scheduledDays.isEmpty {
            return "Schedule enabled"
        }
        
        if let firstDay = scheduledDays.first, scheduledDays.count == 1 {
            if cleanScheduledTime.isEmpty {
                return firstDay
            } else {
                return "\(firstDay), \(cleanScheduledTime)"
            }
        }
        
        if cleanScheduledTime.isEmpty {
            return "\(scheduledDays.count) days selected"
        } else {
            return "\(scheduledDays.count) days, \(cleanScheduledTime)"
        }
    }
    
    // MARK: - Form
    
    private var editForm: some View {
        VStack(spacing: 18) {
            deckInformationSection
            
            coverIconSection
            
            scheduleSection
        }
    }
    
    private var deckInformationSection: some View {
        formCard(title: "Deck Information", systemImage: "text.book.closed") {
            VStack(spacing: 14) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Description", text: $description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...5)
                
                TextField("Category", text: $category)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private var coverIconSection: some View {
        formCard(title: "Cover Icon", systemImage: "square.grid.3x3.fill") {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 58, maximum: 72), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        coverIconName = icon
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    coverIconName == icon
                                    ? Color.accentColor.opacity(0.18)
                                    : Color(.secondarySystemGroupedBackground)
                                )
                                .frame(height: 58)
                            
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(
                                    coverIconName == icon
                                    ? Color.accentColor
                                    : Color.secondary
                                )
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    coverIconName == icon
                                    ? Color.accentColor
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var scheduleSection: some View {
        formCard(title: "Schedule", systemImage: "calendar.badge.clock") {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Enable Schedule", isOn: $isScheduled)
                
                if isScheduled {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 145), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        ForEach(availableDays, id: \.self) { day in
                            dayButton(day)
                        }
                    }
                    
                    TextField("Optional time, example: 19:00", text: $scheduledTime)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
        }
    }
    
    private func dayButton(_ day: String) -> some View {
        Button {
            toggleDay(day)
        } label: {
            HStack {
                Text(day)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: scheduledDays.contains(day) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(scheduledDays.contains(day) ? Color.accentColor : Color.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        scheduledDays.contains(day)
                        ? Color.accentColor.opacity(0.12)
                        : Color(.secondarySystemGroupedBackground)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }
    
    // MARK: - Logic
    
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
        updatedDeck.title = cleanTitle
        updatedDeck.description = cleanDescription
        updatedDeck.category = cleanCategory
        updatedDeck.coverIconName = coverIconName
        
        updatedDeck.isScheduled = isScheduled
        updatedDeck.scheduledDays = isScheduled ? scheduledDays : []
        updatedDeck.scheduledTime = isScheduled && !cleanScheduledTime.isEmpty ? cleanScheduledTime : nil
        
        await onSave(updatedDeck)
        
        isSaving = false
        dismiss()
    }
    
    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var cleanDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var cleanCategory: String {
        category.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var cleanScheduledTime: String {
        scheduledTime.trimmingCharacters(in: .whitespacesAndNewlines)
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
