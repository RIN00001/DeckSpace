//
//  LoginViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("LoginView Tests")
@MainActor
struct LoginViewTests {
    
    @Test("LoginView Initialization")
    func testLoginViewInitialization() async throws {
        let _ = LoginView()
    }
}
