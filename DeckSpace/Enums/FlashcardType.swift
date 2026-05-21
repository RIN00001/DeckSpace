//
//  FlashcardType.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation

enum FlashcardType: String, Codable, CaseIterable, Identifiable {
    case intro
    case multipleChoice
    case paragraph

    var id: String { rawValue }

    var title: String {
        switch self {
        case .intro:
            return "Intro"
        case .multipleChoice:
            return "Multiple Choice"
        case .paragraph:
            return "Paragraph"
        }
    }

    var iconName: String {
        switch self {
        case .intro:
            return "info.circle.fill"
        case .multipleChoice:
            return "checklist.checked"
        case .paragraph:
            return "text.alignleft"
        }
    }

    var isScored: Bool {
        switch self {
        case .intro:
            return false
        case .multipleChoice, .paragraph:
            return true
        }
    }
}
