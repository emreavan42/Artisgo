import SwiftUI

struct NotificationsView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToConversation: Conversation? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.notifications) { notification in
                        Button {
                            handleNotificationTap(notification)
                        } label: {
                            NotificationRow(notification: notification)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .navigationDestination(item: $navigateToConversation) { conversation in
                ChatView(conversation: conversation)
            }
        }
    }

    private func handleNotificationTap(_ notification: NotificationItem) {
        viewModel.markNotificationRead(notification.id)
        if notification.type == .message,
           let conversation = viewModel.conversations.first(where: {
               $0.artisanName == notification.relatedUserName
           }) {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.selectedTab = .messages
                navigateToConversation = conversation
            }
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(.subheadline.weight(.medium))
                Text(notification.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(notification.timestamp)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if !notification.isRead {
                    Circle()
                        .fill(ArtisgoTheme.orange)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(14)
        .background(notification.isRead ? Color(.secondarySystemGroupedBackground) : ArtisgoTheme.orange.opacity(0.05))
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
    }

    private var iconColor: Color {
        switch notification.type {
        case .message: return .blue
        case .devis: return .green
        case .chantier: return ArtisgoTheme.orange
        case .avis: return .yellow
        case .system: return .secondary
        }
    }
}
