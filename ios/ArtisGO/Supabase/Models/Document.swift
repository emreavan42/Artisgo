import Foundation

/// Type de document pour un artisan
enum DocumentType: String, Codable {
    case assurance
    case certification
    case kbis
    case facture
    case devis
    case autre
}

/// Modèle correspondant à la table "documents" dans Supabase
/// Représente un document professionnel privé de l'artisan
/// (assurance décennale, Kbis, certifications RGE/Qualibat, factures, devis…)
struct Document: Codable, Identifiable {
    let id: UUID
    let artisanId: UUID
    let type: DocumentType
    let url: String
    let nomFichier: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case artisanId = "artisan_id"
        case type
        case url
        case nomFichier = "nom_fichier"
        case createdAt = "created_at"
    }
}
