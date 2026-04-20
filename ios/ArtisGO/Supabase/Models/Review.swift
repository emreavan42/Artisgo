import Foundation

/// Modèle correspondant à la table "reviews" dans Supabase
/// Représente l'avis laissé par un particulier sur un artisan,
/// optionnellement rattaché à un chantier précis
struct Review: Codable, Identifiable {
    let id: UUID
    let artisanId: UUID
    let auteurId: UUID
    let chantierId: UUID?
    let note: Int
    let commentaire: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case artisanId = "artisan_id"
        case auteurId = "auteur_id"
        case chantierId = "chantier_id"
        case note
        case commentaire
        case createdAt = "created_at"
    }
}
