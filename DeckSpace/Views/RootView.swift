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
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            
            CreateDeckView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "safari.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
