//
//  ProfileViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("ProfileView Tests")
@MainActor
struct ProfileViewTests {
    
    @Test("ProfileView Initialization")
    func testProfileViewInitialization() async throws {
        let _ = ProfileView()
    }
}
