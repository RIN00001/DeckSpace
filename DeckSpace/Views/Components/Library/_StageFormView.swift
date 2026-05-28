//
//  _StageFormView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct _StageFormView: View {
    @ObservedObject var viewModel: StageViewModel
    let deckId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerSection

            VStack(spacing: 14) {
                TextField("Stage title", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)

                TextField("Description", text: $viewModel.description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }

            addButton
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.separator).opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 8, x: 0, y: 4)
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                    .frame(width: 44, height: 44)

                Image(systemName: "folder.badge.plus")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Add Stage")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Create a new learning stage for this deck.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var addButton: some View {
        Button {
            Task {
                await viewModel.createStage(deckId: deckId)
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(viewModel.isLoading ? "Adding Stage..." : "Add Stage")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(viewModel.canCreateStage ? Color.accentColor : Color.gray.opacity(0.35))
            )
            .foregroundStyle(.white)
        }
        .disabled(!viewModel.canCreateStage || viewModel.isLoading)
    }
}

#Preview {
    _StageFormView(
        viewModel: StageViewModel(),
        deckId: "deck_001"
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
