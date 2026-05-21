//
//  AppUser.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var username: String
    var email: String
    var profileImageUrl: String?
    var profileIconName: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String? = nil,
        username: String,
        email: String,
        profileImageUrl: String? = nil,
        profileIconName: String? = "person.crop.circle.fill",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.profileIconName = profileIconName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
