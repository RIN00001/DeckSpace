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
        HStack(alignment: .top, spacing: 16) {
            iconView

            VStack(alignment: .leading, spacing: 10) {
                titleSection

                if !deck.description.isEmpty {
                    Text(deck.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                metadataRow
            }

            Spacer(minLength: 10)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.accentColor.opacity(0.16))
                .frame(width: 64, height: 64)

            Image(systemName: deck.coverIconName ?? "book.closed.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(deck.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                Text(deck.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())

                visibilityBadge
            }
        }
    }

    private var visibilityBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: deck.isPublished ? "globe" : "lock.fill")

            Text(deck.isPublished ? "Published" : "Private")
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(deck.isPublished ? .green : .secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            (deck.isPublished ? Color.green : Color.secondary)
                .opacity(0.12)
        )
        .clipShape(Capsule())
    }

    private var metadataRow: some View {
        HStack(spacing: 10) {
            Label(stageText, systemImage: "rectangle.stack.fill")

            if deck.isScheduled {
                Label("Scheduled", systemImage: "calendar")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var stageText: String {
        deck.stageCount == 1 ? "1 Stage" : "\(deck.stageCount) Stages"
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
    .background(Color(.systemGroupedBackground))
}
