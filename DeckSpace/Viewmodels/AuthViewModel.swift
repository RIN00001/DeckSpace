//
//  AuthViewModel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var currentUser: AppUser?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    private let userService = UserService.shared
    
    init() {
        Task {
            await checkCurrentUser()
        }
    }
    
    func checkCurrentUser() async {
        guard let userId = authService.currentUserId else {
            self.currentUser = nil
            self.isAuthenticated = false
            return
        }
        
        do {
            let user = try await userService.fetchUser(userId: userId)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func register(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let firebaseUser = try await authService.register(email: email, password: password)
            
            let appUser = AppUser(
                id: firebaseUser.uid,
                username: username,
                email: email
            )
            
            try await userService.createUserDocument(user: appUser)
            
            self.currentUser = appUser
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let firebaseUser = try await authService.login(email: email, password: password)
            let appUser = try await userService.fetchUser(userId: firebaseUser.uid)
            
            self.currentUser = appUser
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func logout() {
        do {
            try authService.logout()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
