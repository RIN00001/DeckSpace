//
//  SessionItem.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation

struct SessionItem: Identifiable {
    let id = UUID()
    let flashcard: Flashcard
    let dynamicChoices: [Answer]
}
