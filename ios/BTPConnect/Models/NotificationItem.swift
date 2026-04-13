import Foundation

nonisolated struct NotificationItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let timestamp: String
    let isRead: Bool
    let type: NotificationType
}

nonisolated enum NotificationType: String, Hashable, Sendable {
    case message
    case devis
    case chantier
    case avis
    case system
}
