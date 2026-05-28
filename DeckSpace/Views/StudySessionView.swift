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
    
    // Dynamic detection for running on macOS/iPad vs iPhone screen sizes
    #if os(macOS)
    private let isLargeScreen = true
    #else
    private let isLargeScreen = UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    #endif
    
    var body: some View {
        ScrollView { // Added ScrollView to prevent keyboard/layout clipping on smaller screens
            VStack(spacing: isLargeScreen ? 32 : 20) {
                if studySession.isLoading {
                    loadingSection
                } else if studySession.isSessionFinished {
                    SummarySection(
                        studySession: studySession,
                        userId: userId,
                        deckId: deck.id ?? "",
                        stage: stage,
                        isLargeScreen: isLargeScreen,
                        onTryAgain: {
                            resetParagraphContext()
                            Task {
                                await studySession.buildSessionQUeue(userId: userId, deckId: deck.id ?? "", stageId: stage.id ?? "")
                            }
                        }
                    )
                } else if let currentItem = studySession.currentItem {
                    
                    // Main Session Layout Engine
                    VStack(spacing: isLargeScreen ? 24 : 16) {
                        SessionHeaderSection(studySession: studySession, isLargeScreen: isLargeScreen)
                        
                        // Dynamic Prompt Card Box
                        VStack {
                            if let icon = currentItem.flashcard.imageIconName, !icon.isEmpty {
                                Image(systemName: icon)
                                    .font(.system(size: isLargeScreen ? 60 : 40))
                                    .foregroundColor(.accentColor)
                                    .padding(.top)
                            }
                            
                            Text(currentItem.flashcard.promptText ?? "No text prompt defined.")
                                .font(isLargeScreen ? .title3 : .body) // Dynamic readable typography scales
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(isLargeScreen ? 32 : 20)
                        }
                        .frame(maxWidth: .infinity)
                        // Sets an adaptive minimum size balance relative to screen real estate
                        .frame(minHeight: isLargeScreen ? 280 : 160)
                        .background(
                            RoundedRectangle(cornerRadius: 18).fill(Color.gray.opacity(0.1))
                        )
                        
                        // Interface Controls Target Area
                        VStack(spacing: 12) {
                            switch currentItem.flashcard.type {
                            case .intro:
                                IntroCardInterface(currentItem: currentItem, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage, isLargeScreen: isLargeScreen)
                                
                            case .multipleChoice:
                                multipleChoiceInterface(choices: currentItem.dynamicChoices, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage, isLargeScreen: isLargeScreen)
                                
                            case .paragraph:
                                ParagraphInterface(currentItem: currentItem, studySession: studySession, userId: userId, deckId: deck.id ?? "", stage: stage, paragraphUserText: $paragraphUserText, isParagraphAnswerRevealed: $isParagraphAnswerRevealed, isLargeScreen: isLargeScreen)
                            }
                        }
                    }
                    .frame(maxWidth: isLargeScreen ? 700 : .infinity)
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    EmptyStageStateSection(isLargeScreen: isLargeScreen)
                }
                
                if let error = studySession.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(isLargeScreen ? 40 : 16)
        }
        .navigationTitle(stage.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await studySession.buildSessionQUeue(userId: userId, deckId: deck.id ?? "", stageId: stage.id ?? "")
        }
        .onChange(of: studySession.currentItemIndex) { _ in
            resetParagraphContext()
        }
    }
    
    private var loadingSection: some View {
        VStack {
            Spacer()
            ProgressView("Checking flashcards...")
                .scaleEffect(isLargeScreen ? 1.5 : 1.0)
            Spacer()
        }
        .frame(minHeight: isLargeScreen ? 400 : 200)
    }
    
    private var emptyStageStateSection: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.fill")
                .font(isLargeScreen ? .largeTitle : .title)
                .foregroundColor(.secondary)
            Text("No flashcards found configured for this stage.")
                .font(isLargeScreen ? .body : .subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(minHeight: isLargeScreen ? 400 : 200)
    }
    
    private func resetParagraphContext() {
        paragraphUserText = ""
        isParagraphAnswerRevealed = false
    }
}
