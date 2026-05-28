//
//  DiscoverViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("DiscoverView Tests")
@MainActor
struct DiscoverViewTests {
    
    @Test("DiscoverView Initialization")
    func testDiscoverViewInitialization() async throws {
        let _ = DiscoverView()
    }
}
