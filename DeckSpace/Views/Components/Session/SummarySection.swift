//
//  SummarySection.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct SummarySection: View {
    @Environment(\.dismiss) private var dismiss
    let studySession: StudySessionViewModel
    let userId: String
    let deckId: String
    let stage: Stage
    let isLargeScreen: Bool
    
    let onTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: isLargeScreen ? 40 : 24) {
            Spacer()
            ZStack {
                // Color chage based on if you pass or not
                Circle()
                    .fill(studySession.wasStagePassed ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: isLargeScreen ? 160 : 100, height: isLargeScreen ? 160 : 100)
                
                // Pass or not indication
                Image(systemName: studySession.wasStagePassed ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: isLargeScreen ? 72 : 48))
                    .foregroundColor(studySession.wasStagePassed ? .green : .red)
            }
            
            // Small summary  for indication if you pass or not and score
            VStack(spacing: isLargeScreen ? 16 : 8) {
                Text(studySession.wasStagePassed ? "Stage Cleared!" : "Score Target Failed")
                    .font(isLargeScreen ? .largeTitle.bold() : .title.bold())
                
                Text("Accuracy score: \(Int(studySession.finalScoreRate * 100))%")
                    .font(isLargeScreen ? .title2 : .body)
                    .foregroundColor(.secondary)
                
                Text("(Required benchmark parameter: 70%)")
                    .font(isLargeScreen ? .body : .caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                if studySession.wasStagePassed {
                    dismiss()
                } else {
                    onTryAgain()
                }
            } label: {
                Text(studySession.wasStagePassed ? "Finish Session" : "Try Again")
                    .font(isLargeScreen ? .title3.bold() : .headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(studySession.wasStagePassed ? Color.blue : Color.gray)
                    .cornerRadius(14)
            }
        }
        .frame(minHeight: isLargeScreen ? 500 : 300)
    }
}
