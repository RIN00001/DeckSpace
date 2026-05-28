//
//  _FlashcardRowView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _FlashcardRowView: View {
    let flashcard: Flashcard

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            iconView

            VStack(alignment: .leading, spacing: 8) {
                titleSection

                metadataRow
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                Text("#\(flashcard.orderIndex + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.separator).opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titleText)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                typeBadge

                difficultyBadge

                if flashcard.isMastered {
                    masteredBadge
                }
            }
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 10) {
            Label(
                "Score \(flashcard.masteryScore)/\(flashcard.masteryThreshold)",
                systemImage: "chart.bar.fill"
            )

            Label(
                "\(flashcard.correctCount) correct",
                systemImage: "checkmark.circle.fill"
            )
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var typeBadge: some View {
        Label(flashcard.type.title, systemImage: flashcard.type.iconName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var difficultyBadge: some View {
        Label(flashcard.difficultyLevel.title, systemImage: flashcard.difficultyLevel.iconName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }

    private var masteredBadge: some View {
        Label("Mastered", systemImage: "checkmark.seal.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.green)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
    }

    private var titleText: String {
        switch flashcard.type {
        case .intro:
            return flashcard.explanationText ?? "Intro Card"

        case .multipleChoice, .paragraph:
            return flashcard.promptText ?? "Question Card"
        }
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.16))
                .frame(width: 52, height: 52)

            Image(systemName: displayIconName)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
        }
    }

    private var displayIconName: String {
        if let imageIconName = flashcard.imageIconName, !imageIconName.isEmpty {
            return imageIconName
        }

        return flashcard.type.iconName
    }
}

#Preview {
    _FlashcardRowView(
        flashcard: Flashcard(
            deckId: "deck_001",
            stageId: "stage_001",
            type: .multipleChoice,
            orderIndex: 0,
            difficultyLevel: .easy,
            promptText: "What does @State do in SwiftUI?",
            imageIconName: "swift"
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
