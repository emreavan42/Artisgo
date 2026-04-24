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

    func sendMessage(text: String, in conversation: Conversation) {
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            text: text,
            isFromClient: true,
            timestamp: "À l'instant",
            isRead: false,
            isPinned: false,
            reaction: nil,
            attachmentType: nil,
            attachmentName: nil,
            attachmentSize: nil
        )
        chatMessages.append(newMessage)

        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            let conv = conversations[index]
            conversations[index] = Conversation(
                id: conv.id,
                artisanName: conv.artisanName,
                profession: conv.profession,
                lastMessage: text,
                timestamp: "À l'instant",
                unreadCount: conv.unreadCount,
                isProSeen: false,
                lastConnection: conv.lastConnection,
                avatarURL: conv.avatarURL,
                isPinned: conv.isPinned
            )
        }
    }

    // Envoi d'un message de type "adresse"
    func sendAddress(_ address: String, in conversation: Conversation) {
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            text: "",
            isFromClient: true,
            timestamp: "À l'instant",
            isRead: false,
            isPinned: false,
            reaction: nil,
            attachmentType: .location,
            attachmentName: address,
            attachmentSize: nil
        )
        chatMessages.append(newMessage)
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            let conv = conversations[index]
            conversations[index] = Conversation(
                id: conv.id,
                artisanName: conv.artisanName,
                profession: conv.profession,
                lastMessage: "📍 Adresse partagée",
                timestamp: "À l'instant",
                unreadCount: conv.unreadCount,
                isProSeen: false,
                lastConnection: conv.lastConnection,
                avatarURL: conv.avatarURL,
                isPinned: conv.isPinned
            )
        }
    }

    func markNotificationRead(_ id: String) {
    if let index = notifications.firstIndex(where: { $0.id == id }) {
        var notif = notifications[index]
        notifications.remove(at: index)
        notifications.insert(
            NotificationItem(
                id: notif.id,
                title: notif.title,
                subtitle: notif.subtitle,
                icon: notif.icon,
                timestamp: notif.timestamp,
                isRead: true,
                type: notif.type,
                relatedUserName: notif.relatedUserName
            ),
            at: index
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
    case postChantier
    case messages
    case profile
}
