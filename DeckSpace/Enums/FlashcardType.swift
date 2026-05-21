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
    
    var id: String {
        rawValue
    }
    
    var displayName: String {
        switch self {
        case .intro:
            return "Intro"
        case .multipleChoice:
            return "Multiple Choice"
        case .paragraph:
            return "Paragraph"
        }
    }
}
