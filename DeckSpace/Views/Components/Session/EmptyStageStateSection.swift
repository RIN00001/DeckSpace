//
//  EmptyStageStateSection.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct EmptyStageStateSection: View {
    @Environment(\.dismiss) private var dismiss
    let isLargeScreen: Bool
    var body: some View {
        VStack(spacing: isLargeScreen ? 24 : 12) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.system(size: isLargeScreen ? 64 : 40))
                .foregroundColor(.secondary)
            HStack(spacing: isLargeScreen ? 20 : 12) {
                Text("No flashcards found configured for this stage.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button {
                    dismiss()
                } label: {
                    Text("Return")
                        .font(isLargeScreen ? .body.bold() : .headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: isLargeScreen ? 240 : .infinity)
                        .padding(isLargeScreen ? 16 : 12)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, isLargeScreen ? 40 : 16)

            Spacer()
        }
        .frame(minHeight: isLargeScreen ? 400 : 200)
    }
}
