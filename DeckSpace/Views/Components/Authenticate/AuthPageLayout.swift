//
//  AuthPageLayout.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//



import SwiftUI

struct AuthPageLayout<Content: View>: View {
    
    let title: String
    let subtitle: String
    let systemImage: String
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { proxy in
            let isWideLayout = proxy.size.width >= 820
            
            ScrollView {
                Group {
                    if isWideLayout {
                        HStack(spacing: 48) {
                            assetSection
                                .frame(maxWidth: 420)
                            
                            formSection
                                .frame(maxWidth: 460)
                        }
                    } else {
                        VStack(spacing: 28) {
                            compactAssetSection
                            
                            formSection
                                .frame(maxWidth: 460)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
                .padding(.horizontal, isWideLayout ? 56 : 20)
                .padding(.vertical, 32)
            }
            .background(Color(.systemBackground))
        }
    }
    
    private var assetSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                    .frame(width: 190, height: 190)
                
                Image(systemName: systemImage)
                    .font(.system(size: 76, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("DeckSpace")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Create, organize, and study flashcard decks with stages that match your learning flow.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(36)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 520)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.accentColor.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.accentColor.opacity(0.12), lineWidth: 1)
        }
    }
    
    private var compactAssetSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 92, height: 92)
                
                Image(systemName: systemImage)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            
            Text("DeckSpace")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.top, 12)
    }
    
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
            }
            
            content
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color(.separator).opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
    }
}
