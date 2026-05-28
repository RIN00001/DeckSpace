//
//  HomeStageRowView.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct _HomeStageRowView: View {
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
                    Label("Stage \(stage.orderIndex + 1)", systemImage: "flag.fill")
                    Text("•")
                    Text("\(Int(stage.bestCorrectRate * 100))% best")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

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

    // Penyesuaian Ikon untuk Mode Home/Belajar
    private var iconName: String {
        if stage.isCompleted {
            return "checkmark"
        }
        if stage.isUnlocked {
            return "play.fill"
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
