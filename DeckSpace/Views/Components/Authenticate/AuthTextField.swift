//
//  AuthTextField.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct AuthTextField: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var keyboardType: UIKeyboardType = .default
    var textInputAutocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(textInputAutocapitalization)
                .autocorrectionDisabled()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }
}

#Preview {
    AuthTextField(
        title: "Email",
        placeholder: "Enter your email",
        text: .constant("")
    )
    .padding()
}
