//
//  LibraryViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("LibraryView Tests")
@MainActor
struct LibraryViewTests {
    
    @Test("LibraryView Initialization")
    func testLibraryViewInitialization() async throws {
        let _ = LibraryView()
    }
}
