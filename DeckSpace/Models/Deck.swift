//
//  Deck.swift
//  DeckSpace
//
//  Created by student on 21/05/26.
//

import Foundation
import FirebaseFirestore

struct Deck: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var ownerId: String
    var ownerName: String

    var title: String
    var description: String
    var category: String

    // Firebase Storage is skipped for prototype.
    // Keep imageUrl for future compatibility.
    var coverImageUrl: String?
    var coverIconName: String?

    var stageCount: Int
    var currentStageId: String?

    var isScheduled: Bool
    var scheduledDays: [String]
    var scheduledTime: String?

    var isPublished: Bool
    var isDownloadedCopy: Bool
    var isRemix: Bool

    var originalCreatorId: String
    var originalCreatorName: String
    var originalDeckId: String
    var originalDeckTitle: String

    var sourceOwnerId: String?
    var sourceOwnerName: String?
    var sourceDeckId: String?
    var sourceDeckTitle: String?

    var remixNote: String?
    var downloadCount: Int

    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date?

    init(
        id: String? = nil,
        ownerId: String,
        ownerName: String,
        title: String,
        description: String,
        category: String,
        coverImageUrl: String? = nil,
        coverIconName: String? = "book.closed.fill",
        stageCount: Int = 0,
        currentStageId: String? = nil,
        isScheduled: Bool = false,
        scheduledDays: [String] = [],
        scheduledTime: String? = nil,
        isPublished: Bool = false,
        isDownloadedCopy: Bool = false,
        isRemix: Bool = false,
        originalCreatorId: String = "",
        originalCreatorName: String = "",
        originalDeckId: String = "",
        originalDeckTitle: String = "",
        sourceOwnerId: String? = nil,
        sourceOwnerName: String? = nil,
        sourceDeckId: String? = nil,
        sourceDeckTitle: String? = nil,
        remixNote: String? = nil,
        downloadCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = nil
    ) {
        self.id = id
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.title = title
        self.description = description
        self.category = category
        self.coverImageUrl = coverImageUrl
        self.coverIconName = coverIconName
        self.stageCount = stageCount
        self.currentStageId = currentStageId
        self.isScheduled = isScheduled
        self.scheduledDays = scheduledDays
        self.scheduledTime = scheduledTime
        self.isPublished = isPublished
        self.isDownloadedCopy = isDownloadedCopy
        self.isRemix = isRemix
        self.originalCreatorId = originalCreatorId
        self.originalCreatorName = originalCreatorName
        self.originalDeckId = originalDeckId
        self.originalDeckTitle = originalDeckTitle
        self.sourceOwnerId = sourceOwnerId
        self.sourceOwnerName = sourceOwnerName
        self.sourceDeckId = sourceDeckId
        self.sourceDeckTitle = sourceDeckTitle
        self.remixNote = remixNote
        self.downloadCount = downloadCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
    }
}
