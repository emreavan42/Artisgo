import SwiftUI

struct MessagesListView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText: String = ""
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                ScrollView {
                    VStack(spacing: 12) {
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
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatView(conversation: conversation)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Messagerie")
                        .font(.largeTitle.bold())
                    Text("Conversations chantier")
                        .font(.subheadline.bold())
                        .foregroundStyle(ArtigoTheme.lightBlue)
                }
                Spacer()
                Button { } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(width: 42, height: 42)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
            }
            Text("Une seule barre d'écriture, messages visibles immédiatement, pièces jointes multiples, réponses rapides et message épinglé clair.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 56, height: 56)
                Text(String(conversation.artisanName.prefix(1)))
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.artisanName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(conversation.profession)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if conversation.isProSeen {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption2.bold())
                        Text("Pro a vu")
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
                        .frame(width: 22, height: 22)
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
