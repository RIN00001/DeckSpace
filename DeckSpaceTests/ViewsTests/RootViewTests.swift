//
//  RootViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("RootView Tests")
@MainActor
struct RootViewTests {
    
    @Test("RootView Initialization")
    func testRootViewInitialization() async throws {
        let _ = RootView()
    }
}
