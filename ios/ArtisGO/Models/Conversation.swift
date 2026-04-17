import Foundation

nonisolated struct Conversation: Identifiable, Hashable, Sendable {
    let id: String
    let artisanName: String
    let profession: String
    let lastMessage: String
    let timestamp: String
    let unreadCount: Int
    let isProSeen: Bool
    let lastConnection: String?
    let avatarURL: String?
    let isPinned: Bool
}
