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
    
    var body: some View {
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
                    Text(currentItem.dynamicChoices.first(where: { $0.isCorrect })?.text ?? "No guide metrics provided.")
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
        await studySession.evaluaeAnswer(selectedAnswer: scoreAnswer, userId: userId, deckId: deckId, stage: stage)
    }
}

