import Foundation

/// Modèle correspondant à la table "chantier_photos" dans Supabase
/// Représente une photo attachée à un chantier, avec un ordre d'affichage
struct ChantierPhoto: Codable, Identifiable {
    let id: UUID
    let chantierId: UUID
    let url: String
    let ordre: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case chantierId = "chantier_id"
        case url
        case ordre
        case createdAt = "created_at"
    }
}
