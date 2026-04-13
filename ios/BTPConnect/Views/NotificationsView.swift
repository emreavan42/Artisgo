import SwiftUI

struct NotificationsView: View {
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
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
                        .fill(ArtigoTheme.orange)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(14)
        .background(notification.isRead ? Color(.secondarySystemGroupedBackground) : ArtigoTheme.orange.opacity(0.05))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }

    private var iconColor: Color {
        switch notification.type {
        case .message: return .blue
        case .devis: return .green
        case .chantier: return ArtigoTheme.orange
        case .avis: return .yellow
        case .system: return .secondary
        }
    }
}
