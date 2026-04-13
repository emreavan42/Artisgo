import SwiftUI

struct MessagesListView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText: String = ""
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                searchBar
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.conversations) { conversation in
                            Button {
                                selectedConversation = conversation
                                viewModel.markConversationRead(conversation.id)
                            } label: {
                                ConversationRow(conversation: conversation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    ArtigoLogoView(size: 28)
                    Text("Messagerie")
                        .font(.largeTitle.bold())
                }
                Text("Conversations chantier")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(ArtigoTheme.orange)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Rechercher une conversation...", text: $searchText)
                .font(.subheadline)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 54, height: 54)
                    .overlay {
                        Text(String(conversation.artisanName.prefix(1)))
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                    }
                if conversation.isProSeen {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(conversation.artisanName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if conversation.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(ArtigoTheme.orange)
                    }
                }
                Text(conversation.profession)
                    .font(.caption)
                    .foregroundStyle(ArtigoTheme.orange)
                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if conversation.isProSeen {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption2.bold())
                        Text("Pro a vu le fil")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.green)
                } else if let lastConn = conversation.lastConnection {
                    Text("Dernière connexion à \(lastConn)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(conversation.timestamp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(minWidth: 22, minHeight: 22)
                        .background(ArtigoTheme.orange)
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }
}
