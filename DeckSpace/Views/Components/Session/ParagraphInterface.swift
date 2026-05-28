//
//  ParagraphInterface.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct ParagraphInterface: View {
    let currentItem: SessionItem
    @ObservedObject var studySession: StudySessionViewModel
    let userId: String
    let deckId: String
    let stage: Stage
    
    @Binding var paragraphUserText: String
    @Binding var isParagraphAnswerRevealed: Bool
    let isLargeScreen: Bool
    
    var body: some View {
        VStack(alignment:.leading, spacing: isLargeScreen ? 18 : 12) {
            if !isParagraphAnswerRevealed {
                Text("Type your response memo:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $paragraphUserText)
                    .frame(height: isLargeScreen ? 260 : 180)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                Button {
                    isParagraphAnswerRevealed = true
                } label : {
                    Text("Reveal Model Guideline")
                        .font(isLargeScreen ? .body.bold() : .subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(isLargeScreen ? 18 : 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(paragraphUserText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(paragraphUserText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                
            } else {
                VStack(alignment: .leading, spacing: isLargeScreen ? 16 : 12) {
                    Text("Your Draft:")
                        .font(isLargeScreen ? .body.bold() : .caption.bold())
                        .foregroundColor(.secondary)
                    Text(paragraphUserText.isEmpty ? "[No response recorded]" : paragraphUserText)
                        .padding()
                        .font(isLargeScreen ? .title3 : .body)
                        .italic()
                    
                    Divider()
                    
                    Text("Model Guideline Matrix:")
                        .font(isLargeScreen ? .body.bold() : .caption.bold())
                        .foregroundColor(.secondary)
                    Text(currentItem.dynamicChoices.first(where: { $0.isCorrect })?.text ?? "No guide metrics provided.")
                        .padding()
                        .font(isLargeScreen ? .title3 : .body)
                    
                    HStack(spacing: isLargeScreen ? 20 : 12) {
                        Button {
                            Task {
                                let failedGrade = Answer(id: "self_wrong", flashcardId: currentItem.flashcard.id!, text: "Incorrect", isCorrect: false)
                                await advanceParagraphCard(with: failedGrade)
                            }
                        } label: {
                            Text("Incorrect (Salah)")
                                .font(isLargeScreen ? .body.bold() : .subheadline.bold())
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(isLargeScreen ? 16 : 12)
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
                                .font(isLargeScreen ? .body.bold() : .subheadline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(isLargeScreen ? 16 : 12)
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
        await studySession.evaluaeAnswer(selectedAnswer: scoreAnswer, userId: userId, deckId: deckId, stage: stage)
    }
}
