//
//  DeckSpaceTests.swift
//  DeckSpaceTests
//
//  Created by student on 28/05/26.
//

import Testing
import Foundation
@testable import DeckSpace

@Suite("Authentication Testing")
struct AuthUnitTest {
    let dummyUser = AppUser(id: "user_123", username: "UserTest", email: "userTest@deckspace.com")
    
    @MainActor
    @Test("Auth VM - Init state of View Model")
    func testInitStateVerification() async {
        let viewModel = AuthViewModel()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @MainActor
    @Test("Auth VM - Registering a user and make sure its loading to know it's working")
    func testRegisterFormWorking() async {
        let viewModel = AuthViewModel()
        
        Task {
            await viewModel.register(username: "Joel1", email: "vidp@deckspace.com", password: "12345678vidp")
            #expect(viewModel.isLoading == true)
        }
    }
    
    @MainActor
    @Test("Auth VM - Login a user and make sure its loading to know it's working")
    func testLoginFormWorking() async {
        let viewModel = AuthViewModel()
        
        Task {
            await viewModel.login(email: "vidp@deckspace.com", password: "12345678vidp")
            #expect(viewModel.isLoading == true)
        }
    }
    
    @MainActor
    @Test("Auth VM - Login but the input from user are empty or not valid")
    func testEmptyLoginInput() async {
        let viewModel = AuthViewModel()
        await viewModel.login(email: "", password: "")
        
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.currentUser == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
    
    @MainActor
    @Test("Auth VM - Register but the input is wrong and malformed / wrong criteria")
    func testRegisterMalformedInput() async {
        let viewModel = AuthViewModel()
        await viewModel.register(username: "wsss", email: "wsssAccount@", password: "w555u")
    }
    
    @MainActor
    @Test("Auth VM - Clear user data that's logged when they pressed logged out")
    func testUserLogoutClearData() async {
        let viewModel = AuthViewModel()
        
        viewModel.currentUser = dummyUser
        viewModel.isAuthenticated = true
        
        viewModel.logout()
        
        #expect(viewModel.currentUser == nil)
        #expect(viewModel.isAuthenticated == false)
    }
}
