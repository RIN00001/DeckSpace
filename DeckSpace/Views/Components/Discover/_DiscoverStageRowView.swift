//
//  _DiscoverStageRowView.swift
//  DeckSpace
//
//  Created by student on 28/05/26.
//

import SwiftUI

struct _DiscoverStageRowView: View {
    let stage: Stage
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "list.bullet.clipboard")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stage.title)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                if !stage.description.isEmpty {
                    Text(stage.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}
