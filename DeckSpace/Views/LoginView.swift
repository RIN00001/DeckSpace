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
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    
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
                    
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    
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
                    
                    registerNavigation
                }
                .padding()
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Login to continue learning with DeckSpace.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
    
    private var registerNavigation: some View {
        HStack {
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
