//
//  AuthSecureField.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct AuthSecureField: View {
    
    let id: String
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
                            .id("\(id)-visible")
                    } else {
                        SecureField(placeholder, text: $text)
                            .id("\(id)-secure")
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.oneTimeCode)
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
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
        id: "password",
        title: "Password",
        placeholder: "Enter your password",
        text: .constant("")
    )
    .padding()
}
