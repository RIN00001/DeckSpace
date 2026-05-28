//
//  HomeViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("HomeView Tests")
@MainActor
struct HomeViewTests {
    
    @Test("HomeView Initialization")
    func testHomeViewInitialization() async throws {
        let _ = HomeView()
    }
}
