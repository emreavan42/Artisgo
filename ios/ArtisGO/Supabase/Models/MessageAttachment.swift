import Foundation

/// Type de pièce jointe dans un message
enum MessageAttachmentType: String, Codable {
    case photo
    case pdf
    case gps
}

/// Modèle correspondant à la table "message_attachments" dans Supabase
/// Représente une pièce jointe liée à un message (photo, PDF, ou position GPS)
struct MessageAttachment: Codable, Identifiable {
    let id: UUID
    let messageId: UUID
    let type: MessageAttachmentType
    let url: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case messageId = "message_id"
        case type
        case url
        case latitude
        case longitude
        case createdAt = "created_at"
    }
}
