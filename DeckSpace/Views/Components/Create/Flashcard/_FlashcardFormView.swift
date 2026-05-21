//
//  _FlashcardFormView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _FlashcardFormView: View {
    @ObservedObject var viewModel: FlashcardViewModel

    let deckId: String
    let stageId: String

    private let iconOptions = [
        "",
        "book.closed.fill",
        "swift",
        "questionmark.circle.fill",
        "text.alignleft",
        "checklist.checked",
        "brain.head.profile",
        "lightbulb.fill",
        "code",
        "paintpalette.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Flashcard")
                .font(.headline)

            Picker("Card Type", selection: $viewModel.selectedType) {
                ForEach(FlashcardType.allCases) { type in
                    Label(type.title, systemImage: type.iconName)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)

            Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                ForEach(DifficultyLevel.allCases) { difficulty in
                    Text(difficulty.title)
                        .tag(difficulty)
                }
            }
            .pickerStyle(.menu)

            iconPickerSection

            cardContentSection

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            createButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.1))
        )
    }

    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Optional Icon Placeholder")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: 10
            ) {
                ForEach(iconOptions, id: \.self) { iconName in
                    Button {
                        viewModel.imageIconName = iconName
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.imageIconName == iconName ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                                .frame(height: 44)

                            if iconName.isEmpty {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: iconName)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.imageIconName == iconName ? Color.accentColor : Color.clear, lineWidth: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var cardContentSection: some View {
        switch viewModel.selectedType {
        case .intro:
            introSection

        case .multipleChoice:
            multipleChoiceSection

        case .paragraph:
            paragraphSection
        }
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intro Explanation")
                .font(.subheadline)
                .fontWeight(.semibold)

            TextField("Explain the topic here", text: $viewModel.explanationText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
        }
    }

    private var multipleChoiceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Question")
                .font(.subheadline)
                .fontWeight(.semibold)

            TextField("Question prompt", text: $viewModel.promptText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)

            Text("Answers")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach($viewModel.multipleChoiceAnswers) { $answer in
                HStack(spacing: 10) {
                    Button {
                        viewModel.setCorrectAnswer(answer)
                    } label: {
                        Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(answer.isCorrect ? Color.accentColor : Color.secondary)
                    }
                    .buttonStyle(.plain)

                    TextField("Answer option", text: $answer.text)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Text("Tap the circle to choose the correct answer. Only one correct answer is allowed.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var paragraphSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Question")
                .font(.subheadline)
                .fontWeight(.semibold)

            TextField("Question prompt", text: $viewModel.promptText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)

            Text("Model Answer")
                .font(.subheadline)
                .fontWeight(.semibold)

            TextField("Write the model answer for self-check", text: $viewModel.paragraphModelAnswer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
        }
    }

    private var createButton: some View {
        Button {
            Task {
                await viewModel.createFlashcard(deckId: deckId, stageId: stageId)
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                }

                Text(viewModel.isLoading ? "Adding Flashcard..." : "Add Flashcard")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canCreateFlashcard ? Color.accentColor : Color.gray.opacity(0.35))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canCreateFlashcard || viewModel.isLoading)
    }
}

#Preview {
    _FlashcardFormView(
        viewModel: FlashcardViewModel(),
        deckId: "deck_001",
        stageId: "stage_001"
    )
    .padding()
}
