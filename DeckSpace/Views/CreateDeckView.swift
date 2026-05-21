//
//  CreateDeckView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct CreateDeckView: View {
    @StateObject private var deckViewModel = DeckViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                _DeckFormView(viewModel: deckViewModel)
            }
            .navigationTitle("Create Deck")
        }
    }
}

#Preview {
    CreateDeckView()
}
