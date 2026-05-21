//
//  ProfileView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: authViewModel.currentUser?.profileIconName ?? "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.accentColor)
                
                VStack(spacing: 6) {
                    Text(authViewModel.currentUser?.username ?? "Unknown User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
