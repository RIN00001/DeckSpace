//
//  DiscoverView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                
                Text("Discover")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Public decks will appear here later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Discover")
        }
    }
}

#Preview {
    DiscoverView()
}
