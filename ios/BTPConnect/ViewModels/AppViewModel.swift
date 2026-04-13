import SwiftUI
import MapKit

@Observable
@MainActor
class AppViewModel {
    var selectedTab: AppTab = .home
    var conversations: [Conversation] = SampleData.conversations
    var artisans: [Artisan] = SampleData.artisans
    var notifications: [NotificationItem] = SampleData.notifications
    var chantiers: [Chantier] = SampleData.chantiers
    var chatMessages: [ChatMessage] = SampleData.chatMessages

    var currentLocation: String = "Écully"
    var currentRadius: Int = 40

    var selectedMapFilter: String = "Mixte"
    var selectedRatingFilter: Double? = nil
    var selectedCategory: String = "Tous"

    var totalUnread: Int {
        conversations.reduce(0) { $0 + $1.unreadCount }
    }

    func markConversationRead(_ id: String) {
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            let conv = conversations[index]
            conversations[index] = Conversation(
                id: conv.id,
                artisanName: conv.artisanName,
                profession: conv.profession,
                lastMessage: conv.lastMessage,
                timestamp: conv.timestamp,
                unreadCount: 0,
                isProSeen: conv.isProSeen,
                lastConnection: conv.lastConnection,
                avatarURL: conv.avatarURL,
                isPinned: conv.isPinned
            )
        }
    }

    var filteredArtisans: [Artisan] {
        var result = artisans
        if selectedMapFilter == "Pros" {
            result = result.filter { !$0.isUrgent }
        } else if selectedMapFilter == "Urgent" {
            result = result.filter { $0.isUrgent }
        } else if selectedMapFilter == "Disponibles" {
            result = result.filter { $0.isAvailable }
        }
        if let rating = selectedRatingFilter {
            result = result.filter { $0.rating >= rating }
        }
        if selectedCategory != "Tous" {
            result = result.filter { $0.profession.localizedCaseInsensitiveContains(selectedCategory) }
        }
        result = result.filter { $0.distance <= Double(currentRadius) }
        return result
    }
}

enum AppTab: Int, CaseIterable, Hashable {
    case home
    case search
    case messages
    case favorites
    case profile
}
