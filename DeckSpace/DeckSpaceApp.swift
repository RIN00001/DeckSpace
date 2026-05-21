//
//  DeckSpaceApp.swift
//  DeckSpace
//
//  Created by student on 07/05/26.
//
import SwiftUI
import FirebaseCore

@main
struct DeckSpaceApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
