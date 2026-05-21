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

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .intermediate:
            return "Intermediate"
        case .hard:
            return "Hard"
        }
    }

    var iconName: String {
        switch self {
        case .easy:
            return "leaf.fill"
        case .intermediate:
            return "flame.fill"
        case .hard:
            return "bolt.fill"
        }
    }

    var initialPriorityWeight: Int {
        switch self {
        case .easy:
            return 1
        case .intermediate:
            return 2
        case .hard:
            return 3
        }
    }
}
