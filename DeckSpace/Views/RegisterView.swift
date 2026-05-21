//
//  RegisterView.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                
                VStack(spacing: 18) {
                    AuthTextField(
                        title: "Username",
                        placeholder: "Enter your username",
                        text: $username
                    )
                    
                    AuthTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        keyboardType: .emailAddress,
                        textInputAutocapitalization: .never
                    )
                    
                    AuthSecureField(
                        title: "Password",
                        placeholder: "Create a password",
                        text: $password
                    )

                    AuthSecureField(
                        title: "Confirm Password",
                        placeholder: "Confirm your password",
                        text: $confirmPassword
                    )
                }
                
                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                
                AuthButton(
                    title: "Create Account",
                    isLoading: authViewModel.isLoading
                ) {
                    Task {
                        await authViewModel.register(
                            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                            password: password
                        )
                    }
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
            }
            .padding()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Start creating, studying, and sharing flashcard decks.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
    
    private var validationMessage: String? {
        if !password.isEmpty && password.count < 6 {
            return "Password must be at least 6 characters."
        }
        
        if !confirmPassword.isEmpty && password != confirmPassword {
            return "Password and confirmation do not match."
        }
        
        return nil
    }
    
    private var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
