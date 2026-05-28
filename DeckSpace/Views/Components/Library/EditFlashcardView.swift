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

    private let maxContentWidth: CGFloat = 1120

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
            return !cleanExplanationText.isEmpty

        case .multipleChoice:
            let filledAnswers = multipleChoiceAnswers.filter {
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            let correctAnswers = multipleChoiceAnswers.filter {
                $0.isCorrect &&
                !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }

            return !cleanPromptText.isEmpty &&
            filledAnswers.count >= 2 &&
            correctAnswers.count == 1

        case .paragraph:
            return !cleanPromptText.isEmpty &&
            !cleanParagraphModelAnswer.isEmpty
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
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 860

            ScrollView {
                Group {
                    if isWideLayout {
                        HStack(alignment: .top, spacing: 28) {
                            previewCard
                                .frame(maxWidth: 380)

                            editorContent
                                .frame(maxWidth: 640)
                        }
                    } else {
                        VStack(spacing: 20) {
                            previewCard

                            editorContent
                        }
                    }
                }
                .padding(.horizontal, isWideLayout ? 32 : 16)
                .padding(.vertical, 24)
                .frame(maxWidth: maxContentWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
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

    // MARK: - Preview

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.16))
                        .frame(width: 76, height: 76)

                    Image(systemName: selectedIconName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedType.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(Color.accentColor)
                        .clipShape(Capsule())

                    Text(previewTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(3)
                }

                Spacer()
            }

            previewBody

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Label(selectedDifficulty.title, systemImage: "gauge.with.dots.needle.50percent")

                Label("\(makeAnswerDrafts().count) answer draft(s)", systemImage: "checklist.checked")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }

    private var selectedIconName: String {
        if !cleanIconName.isEmpty {
            return cleanIconName
        }

        return selectedType.iconName
    }

    private var previewTitle: String {
        switch selectedType {
        case .intro:
            return "Intro Card"

        case .multipleChoice:
            return cleanPromptText.isEmpty ? "Question prompt will appear here." : cleanPromptText

        case .paragraph:
            return cleanPromptText.isEmpty ? "Paragraph question will appear here." : cleanPromptText
        }
    }

    @ViewBuilder
    private var previewBody: some View {
        switch selectedType {
        case .intro:
            Text(cleanExplanationText.isEmpty ? "Intro explanation will appear here." : cleanExplanationText)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)

        case .multipleChoice:
            VStack(alignment: .leading, spacing: 10) {
                ForEach(multipleChoiceAnswers.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { answer in
                    HStack(spacing: 8) {
                        Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(answer.isCorrect ? Color.accentColor : Color.secondary)

                        Text(answer.text.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.subheadline)
                    }
                }

                if multipleChoiceAnswers.allSatisfy({ $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                    Text("Answer options will appear here.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

        case .paragraph:
            VStack(alignment: .leading, spacing: 8) {
                Text("Model Answer")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(cleanParagraphModelAnswer.isEmpty ? "Model answer will appear here." : cleanParagraphModelAnswer)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Editor

    private var editorContent: some View {
        VStack(spacing: 18) {
            cardSettingsSection

            iconPickerCard

            dynamicContentSection
        }
    }

    private var cardSettingsSection: some View {
        formCard(title: "Card Settings", systemImage: "slider.horizontal.3") {
            VStack(spacing: 14) {
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
        }
    }

    private var iconPickerCard: some View {
        formCard(title: "Optional Icon Placeholder", systemImage: "square.grid.3x3.fill") {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 56, maximum: 72), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(iconOptions, id: \.self) { iconName in
                    Button {
                        imageIconName = iconName
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    imageIconName == iconName
                                    ? Color.accentColor.opacity(0.18)
                                    : Color(.secondarySystemGroupedBackground)
                                )
                                .frame(height: 56)

                            if iconName.isEmpty {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: iconName)
                                    .foregroundStyle(
                                        imageIconName == iconName
                                        ? Color.accentColor
                                        : Color.secondary
                                    )
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    imageIconName == iconName ? Color.accentColor : Color.clear,
                                    lineWidth: 2
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var dynamicContentSection: some View {
        switch selectedType {
        case .intro:
            formCard(title: "Intro Explanation", systemImage: "text.alignleft") {
                TextField("Explain the topic here", text: $explanationText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(4...8)
            }

        case .multipleChoice:
            formCard(title: "Question", systemImage: "questionmark.circle.fill") {
                TextField("Question prompt", text: $promptText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...5)
            }

            formCard(title: "Answers", systemImage: "checklist.checked") {
                VStack(spacing: 12) {
                    ForEach($multipleChoiceAnswers) { $answer in
                        HStack(spacing: 10) {
                            Button {
                                setCorrectAnswer(answer)
                            } label: {
                                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

        case .paragraph:
            formCard(title: "Question", systemImage: "questionmark.circle.fill") {
                TextField("Question prompt", text: $promptText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...5)
            }

            formCard(title: "Model Answer", systemImage: "text.alignleft") {
                TextField("Write the model answer for self-check", text: $paragraphModelAnswer, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(4...8)
            }
        }
    }

    private func formCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        }
    }

    // MARK: - Logic

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
                    text: cleanParagraphModelAnswer,
                    isCorrect: true
                )
            ]
        }
    }

    private var cleanPromptText: String {
        promptText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanExplanationText: String {
        explanationText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanIconName: String {
        imageIconName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanParagraphModelAnswer: String {
        paragraphModelAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
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
