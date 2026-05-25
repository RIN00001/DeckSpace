//
//  EmptyStageStateSection.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct EmptyStageStateSection: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            HStack(spacing: 12) {
                Text("No flashcards found configured for this stage.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button {
                    dismiss()
                } label: {
                    Text("Return")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
            }

            Spacer()
        }
    }
}

