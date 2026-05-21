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
        HStack(spacing: 12) {
            iconView

            VStack(alignment: .leading, spacing: 6) {
                Text(titleText)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(flashcard.type.title, systemImage: flashcard.type.iconName)

                    Text("•")

                    Label(flashcard.difficultyLevel.title, systemImage: flashcard.difficultyLevel.iconName)

                    if flashcard.isMastered {
                        Text("•")
                        Label("Mastered", systemImage: "checkmark.seal.fill")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            Text("#\(flashcard.orderIndex + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.12))
        )
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
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.accentColor.opacity(0.16))
                .frame(width: 50, height: 50)

            Image(systemName: flashcard.imageIconName?.isEmpty == false ? flashcard.imageIconName! : flashcard.type.iconName)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
        }
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
}
