//
//  EditFlashcardView.swift
//  DeckSpace
//
//  Created by student on 25/05/26.
//

import SwiftUI

struct EditFlashcardView: View {

    @Environment(\.dismiss) private var dismiss

    let flashcard: Flashcard
    let answers: [Answer]
    let onSave: (Flashcard, [AnswerDraft]) async -> Void

    @State private var selectedType: FlashcardType
    @State private var selectedDifficulty: DifficultyLevel

    @State private var promptText: String
    @State private var explanationText: String
    @State private var imageIconName: String

    @State private var multipleChoiceAnswers: [AnswerDraft]
    @State private var paragraphModelAnswer: String

    @State private var isSaving = false

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

    private var canSave: Bool {
        switch selectedType {
        case .intro:
            return !explanationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        case .multipleChoice:
            let filledAnswers = multipleChoiceAnswers.filter {
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            let correctAnswers = multipleChoiceAnswers.filter {
                $0.isCorrect &&
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            return !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            filledAnswers.count >= 2 &&
            correctAnswers.count == 1

        case .paragraph:
            return !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !paragraphModelAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    init(
        flashcard: Flashcard,
        answers: [Answer],
        onSave: @escaping (Flashcard, [AnswerDraft]) async -> Void
    ) {
        self.flashcard = flashcard
        self.answers = answers
        self.onSave = onSave

        _selectedType = State(initialValue: flashcard.type)
        _selectedDifficulty = State(initialValue: flashcard.difficultyLevel)
        _promptText = State(initialValue: flashcard.promptText ?? "")
        _explanationText = State(initialValue: flashcard.explanationText ?? "")
        _imageIconName = State(initialValue: flashcard.imageIconName ?? "")

        let answerDrafts = answers.map {
            AnswerDraft(text: $0.text, isCorrect: $0.isCorrect)
        }

        if flashcard.type == .multipleChoice {
            var paddedAnswers = answerDrafts

            while paddedAnswers.count < 4 {
                paddedAnswers.append(
                    AnswerDraft(
                        text: "",
                        isCorrect: paddedAnswers.isEmpty
                    )
                )
            }

            _multipleChoiceAnswers = State(initialValue: paddedAnswers)
        } else {
            _multipleChoiceAnswers = State(initialValue: [
                AnswerDraft(text: "", isCorrect: true),
                AnswerDraft(text: "", isCorrect: false),
                AnswerDraft(text: "", isCorrect: false),
                AnswerDraft(text: "", isCorrect: false)
            ])
        }

        if flashcard.type == .paragraph {
            _paragraphModelAnswer = State(initialValue: answers.first?.text ?? "")
        } else {
            _paragraphModelAnswer = State(initialValue: "")
        }
    }

    var body: some View {
        Form {
            Section("Card Settings") {
                Picker("Card Type", selection: $selectedType) {
                    ForEach(FlashcardType.allCases) { type in
                        Label(type.title, systemImage: type.iconName)
                            .tag(type)
                    }
                }

                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(DifficultyLevel.allCases) { difficulty in
                        Text(difficulty.title)
                            .tag(difficulty)
                    }
                }
            }

            Section("Optional Icon Placeholder") {
                iconPickerSection
            }

            dynamicContentSection
        }
        .navigationTitle("Edit Flashcard")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedType) { _, newType in
            normalizeFields(for: newType)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await saveFlashcard()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!canSave || isSaving)
            }
        }
    }

    private var iconPickerSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 5),
            spacing: 10
        ) {
            ForEach(iconOptions, id: \.self) { iconName in
                Button {
                    imageIconName = iconName
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(imageIconName == iconName ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
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
                            .stroke(imageIconName == iconName ? Color.accentColor : Color.clear, lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var dynamicContentSection: some View {
        switch selectedType {
        case .intro:
            Section("Intro Explanation") {
                TextField("Explain the topic here", text: $explanationText, axis: .vertical)
                    .lineLimit(4...8)
            }

        case .multipleChoice:
            Section("Question") {
                TextField("Question prompt", text: $promptText, axis: .vertical)
                    .lineLimit(2...5)
            }

            Section("Answers") {
                ForEach($multipleChoiceAnswers) { $answer in
                    HStack(spacing: 10) {
                        Button {
                            setCorrectAnswer(answer)
                        } label: {
                            Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(answer.isCorrect ? Color.accentColor : Color.secondary)
                        }
                        .buttonStyle(.plain)

                        TextField("Answer option", text: $answer.text)
                    }
                }

                Text("Tap the circle to choose the correct answer. Only one correct answer is allowed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

        case .paragraph:
            Section("Question") {
                TextField("Question prompt", text: $promptText, axis: .vertical)
                    .lineLimit(2...5)
            }

            Section("Model Answer") {
                TextField("Write the model answer for self-check", text: $paragraphModelAnswer, axis: .vertical)
                    .lineLimit(4...8)
            }
        }
    }

    private func setCorrectAnswer(_ answer: AnswerDraft) {
        multipleChoiceAnswers = multipleChoiceAnswers.map { currentAnswer in
            AnswerDraft(
                text: currentAnswer.text,
                isCorrect: currentAnswer.id == answer.id
            )
        }
    }

    private func normalizeFields(for type: FlashcardType) {
        switch type {
        case .intro:
            promptText = ""

        case .multipleChoice:
            explanationText = ""

            if multipleChoiceAnswers.isEmpty {
                multipleChoiceAnswers = [
                    AnswerDraft(text: "", isCorrect: true),
                    AnswerDraft(text: "", isCorrect: false),
                    AnswerDraft(text: "", isCorrect: false),
                    AnswerDraft(text: "", isCorrect: false)
                ]
            }

        case .paragraph:
            explanationText = ""
        }
    }

    private func saveFlashcard() async {
        isSaving = true

        var updatedFlashcard = flashcard
        updatedFlashcard.type = selectedType
        updatedFlashcard.difficultyLevel = selectedDifficulty

        let cleanPromptText = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanExplanationText = explanationText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanIconName = imageIconName.trimmingCharacters(in: .whitespacesAndNewlines)

        switch selectedType {
        case .intro:
            updatedFlashcard.promptText = nil
            updatedFlashcard.explanationText = cleanExplanationText

        case .multipleChoice:
            updatedFlashcard.promptText = cleanPromptText
            updatedFlashcard.explanationText = nil

        case .paragraph:
            updatedFlashcard.promptText = cleanPromptText
            updatedFlashcard.explanationText = nil
        }

        updatedFlashcard.imageIconName = cleanIconName.isEmpty ? nil : cleanIconName
        updatedFlashcard.updatedAt = Date()

        await onSave(updatedFlashcard, makeAnswerDrafts())

        isSaving = false
        dismiss()
    }

    private func makeAnswerDrafts() -> [AnswerDraft] {
        switch selectedType {
        case .intro:
            return []

        case .multipleChoice:
            return multipleChoiceAnswers
                .map {
                    AnswerDraft(
                        text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        isCorrect: $0.isCorrect
                    )
                }
                .filter { !$0.text.isEmpty }

        case .paragraph:
            return [
                AnswerDraft(
                    text: paragraphModelAnswer.trimmingCharacters(in: .whitespacesAndNewlines),
                    isCorrect: true
                )
            ]
        }
    }
}

#Preview {
    NavigationStack {
        EditFlashcardView(
            flashcard: Flashcard(
                id: "flashcard_001",
                deckId: "deck_001",
                stageId: "stage_001",
                type: .multipleChoice,
                difficultyLevel: .easy,
                promptText: "What does @State do in SwiftUI?",
                imageIconName: "swift"
            ),
            answers: []
        ) { _, _ in }
    }
}
