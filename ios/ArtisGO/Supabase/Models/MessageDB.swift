import Foundation

/// Modèle correspondant à la table "messages" dans Supabase
/// Représente un message envoyé dans une conversation.
/// Nommé MessageDB car un struct ChatMessage existe déjà
/// dans ios/ArtisGO/Models/ChatMessage.swift (modèle UI local).
struct MessageDB: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let content: String?
    let readAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case content
        case readAt = "read_at"
        case createdAt = "created_at"
    }
}
