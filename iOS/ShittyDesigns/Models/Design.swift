import Foundation
import SwiftUI

struct Design: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let imageURL: String
    let userId: UUID
    let userName: String
    let userAvatarURL: String?
    let likesCount: Int
    let commentsCount: Int
    let createdAt: Date
    let tags: [String]
    let isApproved: Bool
    let needsReview: Bool
    let isFlagged: Bool
    let moderationNotes: String?
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String? = nil, 
         imageURL: String, 
         userId: UUID, 
         userName: String, 
         userAvatarURL: String? = nil,
         likesCount: Int = 0,
         commentsCount: Int = 0,
         createdAt: Date = Date(),
         tags: [String] = [],
         isApproved: Bool = true,
         needsReview: Bool = false,
         isFlagged: Bool = false,
         moderationNotes: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.userId = userId
        self.userName = userName
        self.userAvatarURL = userAvatarURL
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.createdAt = createdAt
        self.tags = tags
        self.isApproved = isApproved
        self.needsReview = needsReview
        self.isFlagged = isFlagged
        self.moderationNotes = moderationNotes
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    let username: String
    let email: String
    let avatarURL: String?
    let bio: String?
    let designsCount: Int
    let followersCount: Int
    let followingCount: Int
    let createdAt: Date
    let isBanned: Bool
    let warningCount: Int
    
    init(id: UUID = UUID(),
         username: String,
         email: String,
         avatarURL: String? = nil,
         bio: String? = nil,
         designsCount: Int = 0,
         followersCount: Int = 0,
         followingCount: Int = 0,
         createdAt: Date = Date(),
         isBanned: Bool = false,
         warningCount: Int = 0) {
        self.id = id
        self.username = username
        self.email = email
        self.avatarURL = avatarURL
        self.bio = bio
        self.designsCount = designsCount
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.createdAt = createdAt
        self.isBanned = isBanned
        self.warningCount = warningCount
    }
}

struct Comment: Identifiable, Codable {
    let id: UUID
    let designId: UUID
    let userId: UUID
    let userName: String
    let userAvatarURL: String?
    let content: String
    let createdAt: Date
    let isFlagged: Bool
    
    init(id: UUID = UUID(),
         designId: UUID,
         userId: UUID,
         userName: String,
         userAvatarURL: String? = nil,
         content: String,
         createdAt: Date = Date(),
         isFlagged: Bool = false) {
        self.id = id
        self.designId = designId
        self.userId = userId
        self.userName = userName
        self.userAvatarURL = userAvatarURL
        self.content = content
        self.createdAt = createdAt
        self.isFlagged = isFlagged
    }
} 