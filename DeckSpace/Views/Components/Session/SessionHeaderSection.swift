//
//  SessionHeaderSection.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct SessionHeaderSection: View {
    @ObservedObject var studySession: StudySessionViewModel
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(studySession.currentItemIndex + 1) of \(studySession.sessionItems.count)")
                
                Spacer()
                
                Text((studySession.currentItem?.flashcard.difficultyLevel.rawValue.uppercased())!).font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4).background(Color.accentColor.opacity(0.15)).foregroundColor(.accentColor).cornerRadius(6)
            }
            ProgressView(value: Double(studySession.currentItemIndex), total: Double(studySession.sessionItems.count)).tint(.accentColor)
        }
        .padding(.bottom, 10)
    }
}
