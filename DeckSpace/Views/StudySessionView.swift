//
//  StudySessionView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct StudySessionView: View {
    let userId: String
    let deck: Deck
    let stage: Stage
    
    @ObservedObject private var studySession = StudySessionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var paragraphUserText: String = ""
    @State private var isParagraphAnswerRevealed: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if studySession.isLoading {
                Spacer()
                ProgressView("Checking flashcards...")
                Spacer()
            } else if studySession.isSessionFinished {
                SummarySection(
                    studySession: studySession,
                    userId: userId,
                    deckId: deck.id ?? "",
                    stage: stage,
                    onTryAgain: {
                        resetParagraphContext()
                        Task {
                            await studySession.buildSessionQUeue(userId: userId, deckId: deck.id ?? "", stageId: stage.id ?? "")
                        }
                    }
                )
            } else if let currentItem = studySession.currentItem {
                SessionHeaderSection(studySession: studySession)
                
                VStack {
                    if let icon = currentItem.flashcard.imageIconName, !icon.isEmpty {
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                            .padding(.top)
                    }
                    Text(currentItem.flashcard.promptText ?? "No text prompt defined.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth:.infinity, minHeight: 160)
                .background(
                    RoundedRectangle(cornerRadius: 18).fill(Color.gray.opacity(0.1))
                )
                VStack(spacing: 12) {
                    switch currentItem.flashcard.type {
                    case .intro:
                        IntroCardInterface(currentItem: currentItem, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage)
                        
                    case .multipleChoice:
                        multipleChoiceInterface(choices: currentItem.dynamicChoices, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage)
                        
                    case .paragraph:
                        ParagraphInterface(currentItem: currentItem, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage, paragraphUserText: $paragraphUserText, isParagraphAnswerRevealed: $isParagraphAnswerRevealed)
                    }
                }
                
                Spacer()
            } else {
                emptyStageStateSection
            }
            if let error = studySession.errorMessage {
                Text(error).font(.footnote).foregroundColor(.red).padding()
            }
        }.padding()
            .navigationTitle(stage.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await studySession.buildSessionQUeue(userId: userId, deckId: deck.id ?? "", stageId: stage.id ?? "")
            }
            .onChange(of: studySession.currentItemIndex) { _ in
                resetParagraphContext()
            }
    }
    
    private var emptyStageStateSection: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No flashcards found configured for this stage.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    
    private func resetParagraphContext() {
        paragraphUserText = ""
        isParagraphAnswerRevealed = false
    }
}
