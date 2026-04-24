import SwiftUI
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: - Modèle d'une pièce jointe en attente d'envoi
struct PendingAttachment: Identifiable, Equatable {
    enum Kind: Equatable {
        case photo
        case video
        case pdf
    }
    let id: UUID = UUID()
    let kind: Kind
    let image: UIImage?
    let url: URL?
    let name: String
}

struct ChatView: View {
    let conversation: Conversation
    @Environment(AppViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @State private var showAttachmentMenu: Bool = false
    @State private var showEmojiPicker: Bool = false

    // États pour la sélection de fichiers
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var showPhotoPicker: Bool = false
    @State private var showCamera: Bool = false
    @State private var cameraMode: CameraMode = .photo
    @State private var showPDFImporter: Bool = false
    @State private var pendingAttachments: [PendingAttachment] = []
    @State private var showAddressSheet: Bool = false
    @State private var adressePromptShown: Bool = false
    @State private var adressePromptDismissed: Bool = false

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
            if adressePromptShown && !adressePromptDismissed {
                adressePrompt
            }
            if !pendingAttachments.isEmpty {
                attachmentsPreview
            }
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
        // Feuille modale du menu d'attachement
        .sheet(isPresented: $showAttachmentMenu) {
            AttachmentMenuSheet(
                onPickPhoto: {
                    showAttachmentMenu = false
                    cameraMode = .photo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                },
                onPickVideo: {
                    showAttachmentMenu = false
                    cameraMode = .video
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCamera = true
                    }
                },
                onPickGallery: {
                    showAttachmentMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPhotoPicker = true
                    }
                },
                onPickPDF: {
                    showAttachmentMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showPDFImporter = true
                    }
                },
                onPickAddress: {
                    showAttachmentMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showAddressSheet = true
                    }
                },
                onCancel: {
                    showAttachmentMenu = false
                }
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddressSheet) {
            EnvoyerAdresseView { address, _ in
                viewModel.sendAddress(address, in: conversation)
            }
        }
        .onChange(of: viewModel.chatMessages.count) { _, count in
            // Auto-prompt après 5 messages échangés, une seule fois
            if count >= 5 && !adressePromptShown && !adressePromptDismissed {
                withAnimation(.easeInOut) { adressePromptShown = true }
            }
        }
        // Sélecteur de la galerie photos/vidéos (multi)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoPickerItems,
            maxSelectionCount: 10,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: photoPickerItems) { _, newItems in
            Task { await loadPickerItems(newItems) }
        }
        // Caméra (photo ou vidéo)
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureProxy(mode: cameraMode) { attachment in
                if let attachment {
                    pendingAttachments.append(attachment)
                }
                showCamera = false
            }
            .ignoresSafeArea()
        }
        // Importateur PDF
        .fileImporter(
            isPresented: $showPDFImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFImport(result)
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
                        .foregroundStyle(ArtisgoTheme.orange)
                    Text(pinned.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ArtisgoTheme.orange.opacity(0.08))
            }
        }
    }

    private var quickReplies: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(SampleData.quickReplies, id: \.label) { reply in
                    Button {
                        messageText = reply.text
                    } label: {
                        Text(reply.label)
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

    // MARK: - Aperçu horizontal des pièces jointes
    // MARK: - Auto-prompt "Partager mon adresse"
    private var adressePrompt: some View {
        HStack(alignment: .top, spacing: 10) {
            ArtisgoLogoView(size: 32)
            VStack(alignment: .leading, spacing: 10) {
                Text("Vous semblez organiser une visite. Souhaitez-vous partager votre adresse exacte ?")
                    .font(.caption)
                    .foregroundStyle(ArtisgoTheme.darkBlue)
                HStack(spacing: 8) {
                    Button {
                        adressePromptDismissed = true
                        showAddressSheet = true
                    } label: {
                        Text("Oui, partager")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ArtisgoTheme.orange)
                            .clipShape(Capsule())
                    }
                    Button {
                        withAnimation { adressePromptDismissed = true }
                    } label: {
                        Text("Pas maintenant")
                            .font(.caption.bold())
                            .foregroundStyle(ArtisgoTheme.darkBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(ArtisgoTheme.lightBlue)
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var attachmentsPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(pendingAttachments) { att in
                    AttachmentThumbnail(attachment: att) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            pendingAttachments.removeAll { $0.id == att.id }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .top) { Divider() }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button {
                showAttachmentMenu = true
            } label: {
                Image(systemName: "plus")
                    .font(.body.bold())
                    .foregroundStyle(ArtisgoTheme.orange)
                    .frame(width: 36, height: 36)
                    .background(ArtisgoTheme.orange.opacity(0.12))
                    .clipShape(Circle())
            }
            HStack(spacing: 6) {
                TextField("Écrire un message", text: $messageText)
                    .font(.subheadline)
                Button {
                    showEmojiPicker.toggle()
                } label: {
                    Image(systemName: "face.smiling")
                        .font(.title3)
                        .foregroundStyle(.secondary)
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
                    .background(canSend ? ArtisgoTheme.orange : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) { Divider() }
    }

    // Activation du bouton Envoyer
    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespaces).isEmpty || !pendingAttachments.isEmpty
    }

    private func sendMessage() {
        guard canSend else { return }
        let trimmed = messageText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            viewModel.sendMessage(text: trimmed, in: conversation)
        } else if !pendingAttachments.isEmpty {
            // Envoi d'un message sans texte (aperçu nominal)
            viewModel.sendMessage(text: "📎 \(pendingAttachments.count) pièce(s) jointe(s)", in: conversation)
        }
        messageText = ""
        pendingAttachments.removeAll()
    }

    // Chargement des éléments sélectionnés depuis la galerie
    private func loadPickerItems(_ items: [PhotosPickerItem]) async {
        for item in items {
            // Tentative image
            if let data = try? await item.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    let att = PendingAttachment(kind: .photo, image: image, url: nil, name: "Photo.jpg")
                    pendingAttachments.append(att)
                    continue
                }
                // Si ce n'est pas une image, on suppose vidéo
                let tmpURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("video_\(UUID().uuidString).mov")
                try? data.write(to: tmpURL)
                let thumb = Self.videoThumbnail(url: tmpURL)
                let att = PendingAttachment(kind: .video, image: thumb, url: tmpURL, name: "Vidéo.mov")
                pendingAttachments.append(att)
            }
        }
        photoPickerItems.removeAll()
    }

    private func handlePDFImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.removeItem(at: tmpURL)
            try? FileManager.default.copyItem(at: url, to: tmpURL)
            let att = PendingAttachment(kind: .pdf, image: nil, url: tmpURL, name: url.lastPathComponent)
            pendingAttachments.append(att)
        case .failure:
            break
        }
    }

    // Miniature vidéo
    nonisolated static func videoThumbnail(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cg = try? generator.copyCGImage(at: .zero, actualTime: nil) {
            return UIImage(cgImage: cg)
        }
        return nil
    }
}

// MARK: - Feuille modale du menu d'attachement
private struct AttachmentMenuSheet: View {
    let onPickPhoto: () -> Void
    let onPickVideo: () -> Void
    let onPickGallery: () -> Void
    let onPickPDF: () -> Void
    let onPickAddress: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Titre
            Text("Joindre un fichier")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                AttachmentMenuRow(icon: "camera.fill", title: "Prendre une photo", action: onPickPhoto)
                Divider().padding(.leading, 64)
                AttachmentMenuRow(icon: "video.fill", title: "Enregistrer une vidéo", action: onPickVideo)
                Divider().padding(.leading, 64)
                AttachmentMenuRow(icon: "photo.on.rectangle.angled", title: "Galerie (photos et vidéos)", action: onPickGallery)
                Divider().padding(.leading, 64)
                AttachmentMenuRow(icon: "doc.fill", title: "Document PDF", action: onPickPDF)
                Divider().padding(.leading, 64)
                AttachmentMenuRow(icon: "mappin.and.ellipse", title: "Envoyer mon adresse", action: onPickAddress)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer()

            Button(action: onCancel) {
                Text("Annuler")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct AttachmentMenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(ArtisgoTheme.orange)
                    .frame(width: 32, height: 32)
                    .background(ArtisgoTheme.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(AttachmentRowButtonStyle())
    }
}

private struct AttachmentRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.primary.opacity(0.06) : Color.clear)
    }
}

// MARK: - Miniature d'une pièce jointe en attente
private struct AttachmentThumbnail: View {
    let attachment: PendingAttachment
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch attachment.kind {
                case .photo:
                    thumbnailImage
                case .video:
                    thumbnailImage
                        .overlay {
                            Image(systemName: "play.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                case .pdf:
                    VStack(spacing: 4) {
                        Image(systemName: "doc.fill")
                            .font(.title2)
                            .foregroundStyle(ArtisgoTheme.orange)
                        Text(attachment.name)
                            .font(.system(size: 9, weight: .medium))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)
                    }
                    .frame(width: 80, height: 80)
                    .background(ArtisgoTheme.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .offset(x: 6, y: -6)
        }
        .padding(.top, 6)
        .padding(.trailing, 6)
    }

    private var thumbnailImage: some View {
        Color(.secondarySystemBackground)
            .frame(width: 80, height: 80)
            .overlay {
                if let img = attachment.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
    }
}

// MARK: - Caméra via UIImagePickerController
enum CameraMode {
    case photo
    case video
}

struct CameraCaptureProxy: View {
    let mode: CameraMode
    let onComplete: (PendingAttachment?) -> Void

    var body: some View {
        #if targetEnvironment(simulator)
        CameraUnavailablePlaceholder(onDismiss: { onComplete(nil) })
        #else
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            CameraPicker(mode: mode, onComplete: onComplete)
        } else {
            CameraUnavailablePlaceholder(onDismiss: { onComplete(nil) })
        }
        #endif
    }
}

private struct CameraUnavailablePlaceholder: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Caméra indisponible")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Installez cette application sur votre appareil via l'app Rork pour utiliser la caméra.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button("Fermer", action: onDismiss)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(ArtisgoTheme.orange)
                    .clipShape(Capsule())
            }
        }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    let mode: CameraMode
    let onComplete: (PendingAttachment?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        switch mode {
        case .photo:
            picker.mediaTypes = [UTType.image.identifier]
            picker.cameraCaptureMode = .photo
        case .video:
            picker.mediaTypes = [UTType.movie.identifier]
            picker.cameraCaptureMode = .video
            picker.videoQuality = .typeHigh
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onComplete: (PendingAttachment?) -> Void
        init(onComplete: @escaping (PendingAttachment?) -> Void) {
            self.onComplete = onComplete
        }

        nonisolated func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let handler = onComplete
            if let image = info[.originalImage] as? UIImage {
                let att = PendingAttachment(kind: .photo, image: image, url: nil, name: "Photo.jpg")
                Task { @MainActor in handler(att) }
                return
            }
            if let videoURL = info[.mediaURL] as? URL {
                let thumb = ChatView.videoThumbnail(url: videoURL)
                let att = PendingAttachment(kind: .video, image: thumb, url: videoURL, name: "Vidéo.mov")
                Task { @MainActor in handler(att) }
                return
            }
            Task { @MainActor in handler(nil) }
        }

        nonisolated func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            let handler = onComplete
            Task { @MainActor in handler(nil) }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: message.isFromClient ? .trailing : .leading, spacing: 4) {
            if let attachmentType = message.attachmentType {
                if attachmentType == .location, let address = message.attachmentName {
                    AdresseMessageView(address: address, isFromClient: message.isFromClient)
                } else {
                    attachmentView(type: attachmentType)
                }
            }
            if !message.text.isEmpty {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isFromClient ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromClient ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
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
                .fill(type == .pdf ? ArtisgoTheme.orange.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                .frame(width: 48, height: 48)
                .overlay {
                    if type == .pdf {
                        VStack(spacing: 2) {
                            Image(systemName: "doc.text.fill")
                                .font(.caption)
                            Text("PDF")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(ArtisgoTheme.orange)
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
        .background(message.isFromClient ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
