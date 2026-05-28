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
        HStack(alignment: .top, spacing: 14) {
            statusIcon

            VStack(alignment: .leading, spacing: 8) {
                titleSection

                if !stage.description.isEmpty {
                    Text(stage.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                metadataRow
            }

            Spacer(minLength: 8)
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
            Text(stage.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                Text("Stage \(stage.orderIndex + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())

                statusBadge
            }
        }
    }

    private var metadataRow: some View {
        HStack(spacing: 10) {
            Label("\(Int(stage.requiredCorrectRate * 100))% required", systemImage: "target")

            Label("\(Int(stage.bestCorrectRate * 100))% best", systemImage: "chart.line.uptrend.xyaxis")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 7, height: 7)

            Text(statusTitle)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(statusColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 48, height: 48)

            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(iconForegroundColor)
        }
    }

    private var iconName: String {
        if isCompleted {
            return "checkmark"
        }

        if stage.isUnlocked {
            return "play.fill"
        }

        return "lock.fill"
    }

    private var iconBackgroundColor: Color {
        if isCompleted {
            return Color.green.opacity(0.18)
        }

        if stage.isUnlocked {
            return Color.accentColor.opacity(0.18)
        }

        return Color.gray.opacity(0.16)
    }

    private var iconForegroundColor: Color {
        if isCompleted {
            return .green
        }

        if stage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    private var statusTitle: String {
        if isCompleted {
            return "Completed"
        }

        if stage.isUnlocked {
            return "Ready"
        }

        return "Locked"
    }

    private var statusColor: Color {
        if isCompleted {
            return .green
        }

        if stage.isUnlocked {
            return Color.accentColor
        }

        return .secondary
    }

    private var isCompleted: Bool {
        stage.isCompleted || stage.bestCorrectRate >= stage.requiredCorrectRate
    }
}

#Preview {
    _HomeStageRowView(
        stage: Stage(
            deckId: "deck_001",
            title: "SwiftUI Basics",
            description: "Learn views, state, bindings, and layout.",
            orderIndex: 0,
            isUnlocked: true,
            requiredCorrectRate: 0.7,
            bestCorrectRate: 0.4
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
