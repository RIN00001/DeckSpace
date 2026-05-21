//
//  _DeckCardView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _DeckCardView: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 14) {
            iconView

            VStack(alignment: .leading, spacing: 6) {
                Text(deck.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(deck.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                metadataRow
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.12))
        )
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.16))
                .frame(width: 58, height: 58)

            Image(systemName: deck.coverIconName ?? "book.closed.fill")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 8) {
            Label(deck.category, systemImage: "tag.fill")

            Text("•")

            Label("\(deck.stageCount) stage", systemImage: "square.stack.3d.up.fill")

            if deck.isScheduled {
                Text("•")

                Label("Scheduled", systemImage: "calendar")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}

#Preview {
    _DeckCardView(
        deck: Deck(
            ownerId: "user_001",
            ownerName: "Calamity",
            title: "SwiftUI Basics",
            description: "Learn the basic concept of SwiftUI views, state, and layout.",
            category: "Programming",
            coverIconName: "swift",
            stageCount: 1,
            isScheduled: true,
            scheduledDays: ["Monday", "Wednesday"],
            scheduledTime: "19:00",
            originalCreatorId: "user_001",
            originalCreatorName: "Calamity",
            originalDeckId: "deck_001",
            originalDeckTitle: "SwiftUI Basics"
        )
    )
    .padding()
}
