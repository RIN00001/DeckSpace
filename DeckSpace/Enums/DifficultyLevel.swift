//
//  DifficultyLevel.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation

enum DifficultyLevel: String, Codable, CaseIterable, Identifiable {
    case easy
    case intermediate
    case hard
    
    var id: String {
        rawValue
    }
    
    var displayName: String {
        switch self {
        case .easy:
            return "Easy"
        case .intermediate:
            return "Intermediate"
        case .hard:
            return "Hard"
        }
    }
}
