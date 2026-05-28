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

            VStack(alignment: .leading, spacing: 12) {
                Text(titleText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 8) {
                    typeBadge
                    difficultyBadge

                    if flashcard.isMastered {
                        masteredBadge
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "Mastery: \(flashcard.masteryScore)/\(flashcard.masteryThreshold)",
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
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 10) {
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
        .padding(.vertical, 18)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 8, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.accentColor.opacity(0.14))
                .frame(width: 58, height: 58)

            Image(systemName: iconName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.top, 2)
    }

    private var typeBadge: some View {
        Label(typeTitle, systemImage: typeIconName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Capsule())
            .lineLimit(1)
    }

    private var difficultyBadge: some View {
        Label(
            flashcard.difficultyLevel.title,
            systemImage: flashcard.difficultyLevel.iconName
        )
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .lineLimit(1)
    }
    
    private var masteredBadge: some View {
        Label("Mastered", systemImage: "checkmark.seal.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.green)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
            .lineLimit(1)
    }

    private var titleText: String {
        let prompt = flashcard.promptText?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !prompt.isEmpty {
            return prompt
        }

        return flashcard.type.title
    }

    private var iconName: String {
        switch flashcard.type {
        case .intro:
            return "info.circle.fill"
        case .multipleChoice:
            return "checklist"
        case .paragraph:
            return "text.alignleft"
        }
    }

    private var typeIconName: String {
        switch flashcard.type {
        case .intro:
            return "info.circle.fill"
        case .multipleChoice:
            return "checklist"
        case .paragraph:
            return "text.alignleft"
        }
    }

    private var typeTitle: String {
        switch flashcard.type {
        case .intro:
            return "Intro"
        case .multipleChoice:
            return "Multiple Choice"
        case .paragraph:
            return "Paragraph"
        }
    }
}
