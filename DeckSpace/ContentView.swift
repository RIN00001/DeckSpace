//
//  ContentView.swift
//  DeckSpace
//
//  Created by student on 07/05/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                RootView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
