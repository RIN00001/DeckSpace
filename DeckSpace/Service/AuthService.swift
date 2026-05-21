//
//  AuthService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseAuth

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    var hasCurrentUser: Bool {
        Auth.auth().currentUser != nil
    }
    
    func register(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }
    
    func login(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}
