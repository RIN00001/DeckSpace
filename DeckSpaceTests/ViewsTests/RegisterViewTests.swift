//
//  RegisterViewTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Foundation
import Testing
import SwiftUI
@testable import DeckSpace

@Suite("RegisterView Tests")
@MainActor
struct RegisterViewTests {
    
    @Test("RegisterView Initialization")
    func testRegisterViewInitialization() async throws {
        let _ = RegisterView()
    }
}
