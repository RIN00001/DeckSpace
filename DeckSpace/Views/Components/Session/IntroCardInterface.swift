//
//  IntroCardInterface.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct IntroCardInterface: View {
    let currentItem: SessionItem
    let studySession: StudySessionViewModel
    let userId: String
    let deckId: String
    let stage: Stage
    
    var body: some View {
        VStack(spacing: 16) {
            Text(currentItem.flashcard.explanationText ?? "No reference definition specified")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    let neutralPlaceholderAnswer = Answer(id: "intro", flashcardId: currentItem.flashcard.id ?? "", text: "Got It", isCorrect: true)
                    await studySession.evaluaeAnswer(selectedAnswer: neutralPlaceholderAnswer, userId: userId, deckId: deckId, stage: stage)
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
}
