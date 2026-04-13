import Foundation

nonisolated struct ChatMessage: Identifiable, Hashable, Sendable {
    let id: String
    let text: String
    let isFromClient: Bool
    let timestamp: String
    let isRead: Bool
    let isPinned: Bool
    let reaction: String?
    let attachmentType: AttachmentType?
    let attachmentName: String?
    let attachmentSize: String?
}

nonisolated enum AttachmentType: String, Hashable, Sendable {
    case pdf
    case photo
    case video
    case location
}
