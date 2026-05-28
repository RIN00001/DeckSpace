//
//  CreateDeckViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("CreateDeckView Tests")
@MainActor
struct CreateDeckViewTests {
    
    @Test("CreateDeckView Initialization")
    func testCreateDeckViewInitialization() async throws {
        let _ = CreateDeckView()
    }
}
