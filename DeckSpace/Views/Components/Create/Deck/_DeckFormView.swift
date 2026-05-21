//
//  _DeckFormView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _DeckFormView: View {
    @ObservedObject var viewModel: DeckViewModel

    private let iconOptions = [
        "book.closed.fill",
        "graduationcap.fill",
        "brain.head.profile",
        "swift",
        "network",
        "text.book.closed.fill",
        "globe.asia.australia.fill",
        "atom",
        "function",
        "paintpalette.fill"
    ]

    private let categoryOptions = [
        "Programming",
        "Language",
        "Biology",
        "Mathematics",
        "Computer Network",
        "Design",
        "General"
    ]

    private let weekdayOptions = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            deckInformationSection

            iconSection

            scheduleSection

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            createButton
        }
        .padding()
    }

    private var deckInformationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deck Information")
                .font(.headline)

            TextField("Deck title", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)

            TextField("Description", text: $viewModel.description, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)

            Picker("Category", selection: $viewModel.category) {
                Text("Select Category").tag("")

                ForEach(categoryOptions, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deck Icon")
                .font(.headline)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 5),
                spacing: 12
            ) {
                ForEach(iconOptions, id: \.self) { iconName in
                    Button {
                        viewModel.coverIconName = iconName
                    } label: {
                        Image(systemName: iconName)
                            .font(.title2)
                            .frame(width: 48, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(viewModel.coverIconName == iconName ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.12))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        viewModel.coverIconName == iconName ? Color.accentColor : Color.clear,
                                        lineWidth: 2
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Add study schedule", isOn: $viewModel.isScheduled)

            if viewModel.isScheduled {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Study Days")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 2),
                        spacing: 8
                    ) {
                        ForEach(weekdayOptions, id: \.self) { day in
                            Button {
                                viewModel.toggleScheduledDay(day)
                            } label: {
                                HStack {
                                    Image(systemName: viewModel.scheduledDays.contains(day) ? "checkmark.circle.fill" : "circle")
                                    Text(day)
                                    Spacer()
                                }
                                .font(.footnote)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.scheduledDays.contains(day) ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("Optional time, example: 19:00", text: $viewModel.scheduledTime)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    private var createButton: some View {
        Button {
            Task {
                await viewModel.createDeck()
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                }

                Text(viewModel.isLoading ? "Creating Deck..." : "Create Deck")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canCreateDeck ? Color.accentColor : Color.gray.opacity(0.35))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!viewModel.canCreateDeck || viewModel.isLoading)
    }
}

#Preview {
    _DeckFormView(viewModel: DeckViewModel())
}
