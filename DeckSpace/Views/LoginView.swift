//
//  LoginView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            AuthPageLayout(
                title: "Welcome Back",
                subtitle: "Login to continue learning with DeckSpace.",
                systemImage: "rectangle.stack.fill"
            ) {
                VStack(spacing: 22) {
                    inputSection
                    
                    messageSection
                    
                    loginButton
                    
                    registerNavigation
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 18) {
            AuthTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: $email,
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never
            )
            
            AuthSecureField(
                id: "login-password",
                title: "Password",
                placeholder: "Enter your password",
                text: $password
            )
        }
    }
    
    @ViewBuilder
    private var messageSection: some View {
        if let errorMessage = authViewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var loginButton: some View {
        AuthButton(
            title: "Login",
            isLoading: authViewModel.isLoading
        ) {
            Task {
                await authViewModel.login(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            }
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
    }
    
    private var registerNavigation: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(.secondary)
            
            NavigationLink {
                RegisterView()
            } label: {
                Text("Register")
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }
    
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
