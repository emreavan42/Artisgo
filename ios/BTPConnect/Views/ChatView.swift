import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @State private var showAttachmentMenu: Bool = false
    @State private var showEmojiPicker: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            pinnedMessage
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.chatMessages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.chatMessages.count) { _, _ in
                    if let last = viewModel.chatMessages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            quickReplies
            inputBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView { emoji in
                messageText += emoji
                showEmojiPicker = false
            }
            .presentationDetents([.height(300)])
        }
    }

    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(conversation.artisanName.prefix(1)))
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                    }
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
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
        .overlay(alignment: .bottom) { Divider() }
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
                    .font(.body.bold())
                    .foregroundStyle(ArtigoTheme.orange)
                    .frame(width: 36, height: 36)
                    .background(ArtigoTheme.orange.opacity(0.12))
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
            HStack(spacing: 6) {
                TextField("Écrire un message", text: $messageText)
                    .font(.subheadline)
                Button {
                    showEmojiPicker.toggle()
                } label: {
                    Text("😊")
                        .font(.title3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(messageText.isEmpty ? Color.gray : ArtigoTheme.orange)
                    .clipShape(Circle())
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) { Divider() }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.sendMessage(text: messageText, in: conversation)
        messageText = ""
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
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundStyle(.blue)
                }
            }
            if let reaction = message.reaction {
                Text(reaction)
                    .font(.title3)
                    .padding(4)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
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
                    } else if type == .photo {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.secondary)
                    } else if type == .video {
                        Image(systemName: "video.fill")
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
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
}
