import Foundation

nonisolated struct Chantier: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let category: String
    let location: String
    let distance: Double
    let isUrgent: Bool
    let description: String
    let budget: String?
}
