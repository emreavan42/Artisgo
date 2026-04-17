import Foundation

enum SampleData {
    static let artisans: [Artisan] = [
        Artisan(id: "1", name: "Julien Mercier", profession: "Rénovation salle de bain", rating: 4.9, distance: 4.2, pricePerSqm: 680, description: "Artisan très terrain spécialisé dans la rénovation complète de salles de bain", isAvailable: true, isUrgent: false, avatarURL: nil, latitude: 45.7780, longitude: 4.8060),
        Artisan(id: "2", name: "Nicolas R", profession: "Électricité", rating: 4.7, distance: 8.1, pricePerSqm: 450, description: "Électricien certifié, interventions rapides et conformes", isAvailable: true, isUrgent: false, avatarURL: nil, latitude: 45.7850, longitude: 4.8320),
        Artisan(id: "3", name: "BTP Durand & Fils", profession: "Rénovation globale", rating: 4.5, distance: 12.3, pricePerSqm: 520, description: "Entreprise familiale de rénovation depuis 25 ans", isAvailable: false, isUrgent: false, avatarURL: nil, latitude: 45.7600, longitude: 4.7900),
        Artisan(id: "4", name: "Marc Leroy", profession: "Plomberie", rating: 4.8, distance: 3.5, pricePerSqm: 390, description: "Plombier chauffagiste, dépannage urgent 7j/7", isAvailable: true, isUrgent: true, avatarURL: nil, latitude: 45.7720, longitude: 4.8150),
        Artisan(id: "5", name: "Sophie Carrelage", profession: "Carrelage & Faïence", rating: 4.6, distance: 6.7, pricePerSqm: 550, description: "Pose de carrelage haut de gamme, salle de bain et cuisine", isAvailable: true, isUrgent: false, avatarURL: nil, latitude: 45.7900, longitude: 4.8400),
        Artisan(id: "6", name: "Pierre Peinture", profession: "Peinture", rating: 4.4, distance: 15.0, pricePerSqm: 320, description: "Peinture intérieure et extérieure, finitions soignées", isAvailable: false, isUrgent: false, avatarURL: nil, latitude: 45.7500, longitude: 4.7700)
    ]

    static let conversations: [Conversation] = [
        Conversation(id: "1", artisanName: "Julien Mercier", profession: "Salle de bain", lastMessage: "Je peux passer jeudi pour relever les...", timestamp: "09:24", unreadCount: 2, isProSeen: true, lastConnection: nil, avatarURL: nil, isPinned: true),
        Conversation(id: "2", artisanName: "Nicolas R", profession: "Électricité", lastMessage: "Le tableau 3 est validé", timestamp: "Hier", unreadCount: 0, isProSeen: true, lastConnection: nil, avatarURL: nil, isPinned: false),
        Conversation(id: "3", artisanName: "BTP Durand & Fils", profession: "Rénovation globale", lastMessage: "Nous avons bien reçu vos plans PDF e...", timestamp: "Mar.", unreadCount: 1, isProSeen: false, lastConnection: "14:32", avatarURL: nil, isPinned: false)
    ]

    static let chatMessages: [ChatMessage] = [
        ChatMessage(id: "1", text: "Bonjour, j'aimerais refaire ma salle de bain complète. Pouvez-vous me faire un devis ?", isFromClient: true, timestamp: "09:15", isRead: true, isPinned: false, reaction: nil, attachmentType: nil, attachmentName: nil, attachmentSize: nil),
        ChatMessage(id: "2", text: "Bonjour ! Bien sûr, pouvez-vous m'envoyer le relevé PDF et une photo du meuble actuel.", isFromClient: false, timestamp: "09:29", isRead: true, isPinned: true, reaction: nil, attachmentType: nil, attachmentName: nil, attachmentSize: nil),
        ChatMessage(id: "3", text: "Je vous joins le relevé et une photo chantier pour préparer la visite.", isFromClient: true, timestamp: "09:31", isRead: true, isPinned: false, reaction: "👏", attachmentType: nil, attachmentName: nil, attachmentSize: nil),
        ChatMessage(id: "4", text: "", isFromClient: true, timestamp: "09:31", isRead: true, isPinned: false, reaction: nil, attachmentType: .pdf, attachmentName: "releve-sdb.pdf", attachmentSize: "248.0 Ko"),
        ChatMessage(id: "5", text: "", isFromClient: true, timestamp: "09:31", isRead: true, isPinned: false, reaction: nil, attachmentType: .photo, attachmentName: "photo-chantier-sdb.jpg", attachmentSize: "469.7 Ko")
    ]

    static let notifications: [NotificationItem] = [
        NotificationItem(id: "1", title: "Nouveau message", subtitle: "Julien Mercier vous a envoyé un message", icon: "message.fill", timestamp: "Il y a 5 min", isRead: false, type: .message, relatedUserName: "Julien Mercier"),
        NotificationItem(id: "2", title: "Devis reçu", subtitle: "BTP Durand & Fils a envoyé un devis", icon: "doc.text.fill", timestamp: "Il y a 2h", isRead: false, type: .devis, relatedUserName: "BTP Durand & Fils"),
        NotificationItem(id: "3", title: "Chantier urgent", subtitle: "Fuite d'eau détectée à Écully", icon: "exclamationmark.triangle.fill", timestamp: "Il y a 4h", isRead: true, type: .chantier, relatedUserName: nil),
        NotificationItem(id: "4", title: "Nouvel avis", subtitle: "Vous avez reçu un avis 5 étoiles", icon: "star.fill", timestamp: "Hier", isRead: true, type: .avis, relatedUserName: nil)
    ]

    static let chantiers: [Chantier] = [
        Chantier(id: "1", title: "Rénovation salle de bain", category: "Salle de bain", location: "Écully", distance: 4.2, isUrgent: false, description: "Rénovation complète d'une salle de bain de 8m²", budget: "8 000 - 12 000 €"),
        Chantier(id: "2", title: "Fuite urgente cuisine", category: "Plomberie", location: "Lyon 3e", distance: 2.1, isUrgent: true, description: "Fuite sous évier, intervention rapide nécessaire", budget: "200 - 500 €"),
        Chantier(id: "3", title: "Installation tableau électrique", category: "Électricité", location: "Villeurbanne", distance: 6.8, isUrgent: false, description: "Remplacement du tableau électrique principal", budget: "1 500 - 3 000 €")
    ]

    static let tradeCategories: [String] = [
        "Tous", "Rénovation salle de bain", "Peinture", "Électricité", "Plomberie", "Carrelage", "Maçonnerie", "Menuiserie", "Toiture", "Isolation"
    ]

    static let chantierCategories: [String] = [
        "Rénovation complète de maison",
        "Rénovation partielle d'appartement",
        "Rénovation salle de bain",
        "Rénovation cuisine",
        "Réfection chambres et pièces de vie",
        "Transformation local commercial",
        "Mise aux normes intérieure",
        "Réagencement pièce ouverte",
        "Extension maison",
        "Aménagement combles",
        "Ravalement de façade",
        "Terrassement"
    ]

    static let quickReplies: [String] = [
        "OK pour jeudi", "Besoin de photos", "Envoyer devis"
    ]
}
