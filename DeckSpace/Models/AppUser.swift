//
//  AppUser.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    
    var username: String
    var email: String
    var profileImageUrl: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String? = nil,
        username: String,
        email: String,
        profileImageUrl: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
