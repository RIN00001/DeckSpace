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
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Stage")
                .font(.headline)

            TextField("Stage title", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)

            TextField("Description", text: $viewModel.description, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            Button {
                Task {
                    await viewModel.createStage(deckId: deckId)
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                    }

                    Text(viewModel.isLoading ? "Adding Stage..." : "Add Stage")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canCreateStage ? Color.accentColor : Color.gray.opacity(0.35))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.canCreateStage || viewModel.isLoading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    _StageFormView(
        viewModel: StageViewModel(),
        deckId: "deck_001"
    )
    .padding()
}
