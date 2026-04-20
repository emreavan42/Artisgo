import Foundation

/// Modèle correspondant à la table "device_tokens" dans Supabase
/// Stocke les tokens APNs des appareils iOS pour l'envoi de notifications push
struct DeviceToken: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let apnsToken: String
    let platform: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case apnsToken = "apns_token"
        case platform
        case createdAt = "created_at"
    }
}
