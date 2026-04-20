import Foundation

/// Modèle correspondant à la table "conversations" dans Supabase
/// Représente un fil de discussion entre un particulier et un artisan,
/// éventuellement lié à un chantier.
/// Nommé ConversationDB pour éviter le conflit avec le struct Conversation
/// existant dans ios/ArtisGO/Models/Conversation.swift (modèle UI local).
struct ConversationDB: Codable, Identifiable {
    let id: UUID
    let chantierId: UUID?
    let particulierId: UUID
    let artisanId: UUID
    let pinnedMessageId: UUID?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case chantierId = "chantier_id"
        case particulierId = "particulier_id"
        case artisanId = "artisan_id"
        case pinnedMessageId = "pinned_message_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
