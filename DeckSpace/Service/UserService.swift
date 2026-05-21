//
//  UserService.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

final class UserService {
    
    static let shared = UserService()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    private var usersCollection: CollectionReference {
        db.collection("users")
    }
    
    func createUserDocument(user: AppUser) async throws {
        guard let userId = user.id else {
            throw NSError(
                domain: "UserService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "User ID is missing."]
            )
        }
        
        try usersCollection.document(userId).setData(from: user)
    }
    
    func fetchUser(userId: String) async throws -> AppUser {
        try await usersCollection.document(userId).getDocument(as: AppUser.self)
    }
    
    func updateUsername(userId: String, username: String) async throws {
        try await usersCollection.document(userId).updateData([
            "username": username,
            "updatedAt": Date()
        ])
    }
}
