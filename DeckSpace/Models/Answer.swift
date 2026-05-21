//
//  Answer.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct Answer: Identifiable, Codable {
    @DocumentID var id: String?
    
    var flashcardId: String
    var text: String
    var isCorrect: Bool
    var orderIndex: Int
    
    init(
        id: String? = nil,
        flashcardId: String,
        text: String,
        isCorrect: Bool,
        orderIndex: Int
    ) {
        self.id = id
        self.flashcardId = flashcardId
        self.text = text
        self.isCorrect = isCorrect
        self.orderIndex = orderIndex
    }
}
