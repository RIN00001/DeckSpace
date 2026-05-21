//
//  HomeView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome, \(authViewModel.currentUser?.username ?? "User")")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Scheduled decks for today will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
