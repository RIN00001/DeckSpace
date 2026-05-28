//
//  CreateDeckView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct CreateDeckView: View {
    @StateObject private var deckViewModel = DeckViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                _DeckFormView(viewModel: deckViewModel)
                    .padding(.top, 12)
                    // 2. Batasi lebar form di iPad/Mac agar tetap proporsional di tengah
                    .frame(maxWidth: sizeClass == .compact ? .infinity : 650)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .navigationTitle("Create Deck")
        }
    }
}

#Preview {
    CreateDeckView()
}
