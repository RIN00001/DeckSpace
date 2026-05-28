//
//  SessionHeaderSection.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct SessionHeaderSection: View {
    @ObservedObject var studySession: StudySessionViewModel
    let isLargeScreen: Bool
    var body: some View {
        VStack(spacing: isLargeScreen ? 12 : 8) {
            HStack {
                Text("\(studySession.currentItemIndex + 1) of \(studySession.sessionItems.count)").font(isLargeScreen ? .body : .subheadline)
                
                Spacer()
                
                Text((studySession.currentItem?.flashcard.difficultyLevel.rawValue.uppercased())!)
                    .font(isLargeScreen ? .caption : .caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, isLargeScreen ? 12 : 8)
                    .padding(.vertical, isLargeScreen ? 6 : 4).background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor).cornerRadius(6)
            }
            ProgressView(value: Double(studySession.currentItemIndex), total: Double(studySession.sessionItems.count)).tint(.accentColor)
                .scaleEffect(x: 1, y: isLargeScreen ? 1.5 : 1, anchor: .center)
        }
        .padding(.bottom, isLargeScreen ? 16 : 10)
    }
}
