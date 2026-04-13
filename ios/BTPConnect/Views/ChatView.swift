import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @Environment(AppViewModel.self) private var viewModel
    @State private var messageText: String = ""
    @State private var showAttachmentMenu: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            pinnedMessage
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.chatMessages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            quickReplies
            inputBar
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
    }

    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button {
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }

            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)
                Text(String(conversation.artisanName.prefix(1)))
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.artisanName)
                    .font(.headline)
                Text(conversation.profession)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 7, height: 7)
                    Text("En ligne")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            if conversation.isProSeen {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.caption2.bold())
                    Text("Pro a vu le fil")
                        .font(.caption2.bold())
                }
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var pinnedMessage: some View {
        Group {
            if let pinned = viewModel.chatMessages.first(where: { $0.isPinned }) {
                HStack(spacing: 8) {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(ArtigoTheme.orange)
                    Text(pinned.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ArtigoTheme.orange.opacity(0.08))
            }
        }
    }

    private var quickReplies: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(SampleData.quickReplies, id: \.self) { reply in
                    Button {
                        messageText = reply
                    } label: {
                        Text(reply)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.vertical, 6)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { showAttachmentMenu.toggle() } label: {
                Image(systemName: "plus")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
            .confirmationDialog("Envoyer", isPresented: $showAttachmentMenu) {
                Button("Photos multiples") { }
                Button("Vidéo courte") { }
                Button("PDF / Devis") { }
                Button("Photo chantier") { }
                Button("Position GPS") { }
                Button("Annuler", role: .cancel) { }
            }

            TextField("Écrire un message", text: $messageText)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())

            Button { } label: {
                Image(systemName: "paperplane.fill")
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(ArtigoTheme.orange)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: message.isFromClient ? .trailing : .leading, spacing: 4) {
            if let attachmentType = message.attachmentType {
                attachmentView(type: attachmentType)
            }

            if !message.text.isEmpty {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isFromClient ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromClient ? ArtigoTheme.orange : Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))
            }

            HStack(spacing: 6) {
                Text(message.timestamp)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if message.isFromClient && message.isRead {
                    Text("Lu")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let reaction = message.reaction {
                reactionBubbles(selected: reaction)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isFromClient ? .trailing : .leading)
    }

    private func attachmentView(type: AttachmentType) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8)
                .fill(type == .pdf ? ArtigoTheme.orange.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                .frame(width: 48, height: 48)
                .overlay {
                    if type == .pdf {
                        VStack(spacing: 2) {
                            Image(systemName: "doc.text.fill")
                                .font(.caption)
                            Text("PDF")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(ArtigoTheme.orange)
                    } else {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.secondary)
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(message.attachmentName ?? "")
                    .font(.caption.bold())
                    .foregroundStyle(message.isFromClient ? .white : .primary)
                Text(message.attachmentSize ?? "")
                    .font(.caption2)
                    .foregroundStyle(message.isFromClient ? .white.opacity(0.7) : .secondary)
            }
        }
        .padding(10)
        .background(message.isFromClient ? ArtigoTheme.orange : Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func reactionBubbles(selected: String) -> some View {
        let reactions = ["❤️", "👍", "👏", "🔥", "✅", "👀"]
        return HStack(spacing: 6) {
            ForEach(reactions, id: \.self) { emoji in
                Text(emoji)
                    .font(.body)
                    .padding(4)
                    .background(emoji == selected ? Color(.systemBlue).opacity(0.15) : Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(emoji == selected ? Color(.systemBlue) : Color.clear, lineWidth: 1.5)
                    )
            }
        }
    }
}
