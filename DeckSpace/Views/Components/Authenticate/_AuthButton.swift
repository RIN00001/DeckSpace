//
//  AuthButton.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import SwiftUI

struct AuthButton: View {
    
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.white)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}

#Preview {
    AuthButton(title: "Login", isLoading: false) {}
        .padding()
}
