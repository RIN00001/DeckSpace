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
    
    @StateObject private var studySession = StudySessionViewModel()
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
                summarySection
            } else if let currentItem = studySession.currentItem {
                sessionHeaderSection
                
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
                        introCardInterface(currentItem: currentItem)
                        
                    case .multipleChoice:
                        multipleChoiceInterface(choices: currentItem.dynamicChoices)
                        
                    case .paragraph:
                        paragraphInterface(currentItem: currentItem)
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
    }
    
    // MARK: - Header Section
    private var sessionHeaderSection: some View {
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
    
    // MARK: - Empty state stage section
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
    
    // MARK: - Summary Section after every state is done (fail or pass)
    private var summarySection: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                // Color chage based on if you pass or not
                Circle()
                    .fill(studySession.wasStagePassed ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                // Pass or not indication
                Image(systemName: studySession.wasStagePassed ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundColor(studySession.wasStagePassed ? .green : .red)
            }
            
            // Small summary  for indication if you pass or not and score
            VStack(spacing: 8) {
                Text(studySession.wasStagePassed ? "Stage Cleared!" : "Score Target Failed")
                    .font(.title.bold())
                
                Text("Accuracy score: \(Int(studySession.finalScoreRate * 100))%")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("(Required benchmark parameter: 70%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                if studySession.wasStagePassed {
                    dismiss()
                } else {
                    resetParagraphContext()
                    Task {
                        await studySession.buildSessionQUeue(userId: userId, deckId: deck.id ?? "", stageId: stage.id ?? "")
                    }
                }
            } label: {
                Text(studySession.wasStagePassed ? "Finish Session" : "Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(studySession.wasStagePassed ? Color.blue : Color.gray)
                    .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Card Types
    // Intro Card
    func introCardInterface(currentItem: SessionItem) -> some View {
        VStack(spacing: 16) {
            Text(currentItem.flashcard.explanationText ?? "No reference definition specified")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    let neutralPlaceholderAnswer = Answer(id: "intro", flashcardId: currentItem.flashcard.id ?? "", text: "Got It", isCorrect: true)
                    await studySession.evaluaeAnswer(selectedAnswer: neutralPlaceholderAnswer, userId: userId, deckId: deck.id ?? "", stage: stage)
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
    
    // Multiple Choice Card
    func multipleChoiceInterface(choices: [Answer]) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(choices) { choice in
                    Button {
                        Task {
                            await studySession.evaluaeAnswer(selectedAnswer: choice, userId: userId, deckId: deck.id ?? "", stage: stage)
                        }
                    } label: {
                        HStack {
                            Text(choice.text)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                        }
                        .padding()
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
    
    // Paragraoh Card
    func paragraphInterface(currentItem: SessionItem) -> some View {
        VStack(alignment:.leading, spacing: 12) {
            if !isParagraphAnswerRevealed {
                Text("Type your response memo:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $paragraphUserText)
                    .frame(height: 180)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                Button {
                    isParagraphAnswerRevealed = true
                } label : {
                    Text("Reveal Model Guideline")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(paragraphUserText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(paragraphUserText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Draft:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text(paragraphUserText.isEmpty ? "[No response recorded]" : paragraphUserText)
                        .font(.body)
                        .italic()
                    
                    Divider()
                    
                    Text("Model Guideline Matrix:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text(currentItem.flashcard.explanationText ?? "No guide metrics provided.")
                        .font(.body)
                    
                    HStack(spacing: 12) {
                        Button {
                            Task {
                                let failedGrade = Answer(id: "self_wrong", flashcardId: currentItem.flashcard.id!, text: "Incorrect", isCorrect: false)
                                await advanceParagraphCard(with: failedGrade)
                            }
                        } label: {
                            Text("Incorrect (Salah)")
                                .font(.subheadline.bold())
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            Task {
                                let passedGrade = Answer(id: "self_correct", flashcardId: currentItem.flashcard.id!, text: "Correct", isCorrect: true)
                                await advanceParagraphCard(with: passedGrade)
                            }
                        } label: {
                            Text("Correct (Benar)")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private func advanceParagraphCard(with scoreAnswer: Answer) async {
        await studySession.evaluaeAnswer(selectedAnswer: scoreAnswer, userId: userId, deckId: deck.id ?? "", stage: stage)
    }
    
    private func resetParagraphContext() {
        paragraphUserText = ""
        isParagraphAnswerRevealed = false
    }
}

// MARK: - Extension Mock Templates for Preview Engine

extension Deck {
    static var previewMock: Deck {
        Deck(
            id: "mock_deck_123",
            ownerId: "student_mambo",
            ownerName: "MAD Mambo Student",
            title: "SwiftUI Masterclass Layouts",
            description: "A comprehensive flashcard deck to study view life cycles and states.",
            category: "iOS Development",
            coverIconName: "book.closed.fill", // Non-optional string fallback configured in your init
            stageCount: 4,
            isScheduled: true,
            scheduledDays: ["Monday", "Thursday"],
            isPublished: false,
            isDownloadedCopy: false,
            isRemix: false,
            originalCreatorId: "student_mambo",
            originalCreatorName: "MAD Mambo Student",
            originalDeckId: "mock_deck_123",
            originalDeckTitle: "SwiftUI Masterclass Layouts",
            downloadCount: 0
        )
    }
}

extension Stage {
    static var previewMock: Stage {
        Stage(
            id: "mock_stage_456",
            deckId: "mock_deck_123",
            title: "Stage 1: State & Layout Basics",
            description: "Mastering standard stack composition paradigms.",
            orderIndex: 1,
            isUnlocked: true,
            isCompleted: false,
            requiredCorrectRate: 0.7,
            bestCorrectRate: 0.0
        )
    }
}

extension Flashcard {
    static func previewMock(type: FlashcardType) -> Flashcard {
        switch type {
        case .intro:
            return Flashcard(
                id: "card_intro_01",
                deckId: "mock_deck_123",
                stageId: "mock_stage_456",
                type: .intro,
                orderIndex: 0,
                difficultyLevel: .easy,
                promptText: "Welcome to Study Session!",
                explanationText: "In this phase, remember that State drives layout. When properties change, SwiftUI redraws automatically.",
                imageIconName: "sparkles" // Non-optional parameter used for icons
            )
        case .multipleChoice:
            return Flashcard(
                id: "card_mc_02",
                deckId: "mock_deck_123",
                stageId: "mock_stage_456",
                type: .multipleChoice,
                orderIndex: 1,
                difficultyLevel: .hard,
                promptText: "Which property wrapper triggers a re-render when mutating data inside an external class reference?",
                imageIconName: "questionmark.circle"
            )
        case .paragraph:
            return Flashcard(
                id: "card_para_03",
                deckId: "mock_deck_123",
                stageId: "mock_stage_456",
                type: .paragraph,
                orderIndex: 2,
                difficultyLevel: .hard,
                promptText: "Explain the architectural optimization differences between an @ObservedObject and a @StateObject lifecycle approach.",
                explanationText: "@StateObject guarantees persistent instance allocation across view redraws, whereas @ObservedObject can accidentally re-initialize data when parent structural layouts update.",
                imageIconName: "doc.text.fill"
            )
        }
    }
}

extension Answer {
    static var previewMCMocks: [Answer] {
        return [
            Answer(id: "ans_1", flashcardId: "card_mc_02", text: "@State (Value types only)", isCorrect: false),
            Answer(id: "ans_2", flashcardId: "card_mc_02", text: "@ObservedObject / @StateObject", isCorrect: true),
            Answer(id: "ans_3", flashcardId: "card_mc_02", text: "@Binding (Reference pass-thru)", isCorrect: false)
        ]
    }
}


// MARK: - Core Xcode Preview Implementations

// 1. Structural Default Preview Loop
#Preview("Main View Entry Lifecycle") {
    NavigationStack {
        StudySessionView(
            userId: "test_user_789",
            deck: .previewMock,
            stage: .previewMock
        )
    }
}

// 2. Direct Preview for Intro layout structure
#Preview("Layout Variant: Intro Card") {
    Group {
        let targetItem = SessionItem(flashcard: .previewMock(type: .intro), dynamicChoices: [])
        let viewInstance = StudySessionView(userId: "test_user_789", deck: .previewMock, stage: .previewMock)
        
        viewInstance.introCardInterface(currentItem: targetItem)
    }
    .padding()
}

// 3. Direct Preview for Multiple Choice Options layout structure
#Preview("Layout Variant: Multiple Choice Options") {
    Group {
        let viewInstance = StudySessionView(userId: "test_user_789", deck: .previewMock, stage: .previewMock)
        
        viewInstance.multipleChoiceInterface(choices: Answer.previewMCMocks)
    }
    .padding()
}

// 4. Direct Preview for Paragraph Response & Matrix Verification
// 4. Direct Preview for Paragraph Response & Matrix Verification
#Preview("Layout Variant: Paragraph Card") {
    Group {
        // Use your existing, working extension framework directly to ensure promptText isn't nil
        let targetItem = SessionItem(
            flashcard: .previewMock(type: .paragraph),
            dynamicChoices: []
        )
        
        let viewInstance = StudySessionView(
            userId: "test_user_789",
            deck: .previewMock,
            stage: .previewMock
        )
        
        VStack(spacing: 20) {
            // Replicate prompt design frame from main body configuration
            VStack {
                if let icon = targetItem.flashcard.imageIconName, !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                        .padding(.top)
                }
                
                Text(targetItem.flashcard.promptText ?? "No text prompt defined.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(Color.gray.opacity(0.1))
            )
            
            // Render interface elements
            viewInstance.paragraphInterface(currentItem: targetItem)
        }
    }
    .padding()
}
