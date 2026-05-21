//
//  AuthSecureField.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct AuthSecureField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

#Preview {
    AuthSecureField(
        title: "Password",
        placeholder: "Enter your password",
        text: .constant("")
    )
    .padding()
}
