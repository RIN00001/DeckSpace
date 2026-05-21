//
//  RootView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("DeckSpace")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Logged in as \(authViewModel.currentUser?.username ?? "Unknown User")")
                        .foregroundStyle(.secondary)
                }
                
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    Text("Logout")
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
