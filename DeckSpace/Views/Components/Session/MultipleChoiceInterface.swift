//
//  MultipleChoiceInterface.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct multipleChoiceInterface: View {
    let choices: [Answer]
    let studySession: StudySessionViewModel
    let userId: String
    let deckId: String
    let stage: Stage
    let isLargeScreen: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: isLargeScreen ? 14 : 10) {
                ForEach(choices) { choice in
                    Button {
                        Task {
                            await studySession.evaluaeAnswer(selectedAnswer: choice, userId: userId, deckId: deckId, stage: stage)
                        }
                    } label: {
                        HStack {
                            Text(choice.text)
                                .font(isLargeScreen ? .title3 : .body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "circle")
                                .font(isLargeScreen ? .title3 : .body)
                                .foregroundColor(.secondary)
                        }
                        .padding(isLargeScreen ? 20 : 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
