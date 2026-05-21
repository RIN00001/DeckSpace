//
//  _StageRowView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _StageRowView: View {
    let stage: Stage

    var body: some View {
        HStack(spacing: 12) {
            statusIcon

            VStack(alignment: .leading, spacing: 5) {
                Text(stage.title)
                    .font(.headline)

                if !stage.description.isEmpty {
                    Text(stage.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    Label("Stage \(stage.orderIndex + 1)", systemImage: "square.stack.3d.up.fill")

                    Text("•")

                    Text("\(Int(stage.bestCorrectRate * 100))% best")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if stage.isUnlocked {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.12))
        )
    }

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 44, height: 44)

            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(iconForegroundColor)
        }
    }

    private var iconName: String {
        if stage.isCompleted {
            return "checkmark"
        }

        if stage.isUnlocked {
            return "lock.open.fill"
        }

        return "lock.fill"
    }

    private var iconBackgroundColor: Color {
        if stage.isCompleted {
            return Color.green.opacity(0.18)
        }

        if stage.isUnlocked {
            return Color.accentColor.opacity(0.18)
        }

        return Color.gray.opacity(0.16)
    }

    private var iconForegroundColor: Color {
        if stage.isCompleted {
            return .green
        }

        if stage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }
}

#Preview {
    _StageRowView(
        stage: Stage(
            deckId: "deck_001",
            title: "SwiftUI Basics",
            description: "Learn views, state, bindings, and layout.",
            orderIndex: 0,
            isUnlocked: true
        )
    )
    .padding()
}
