import SwiftUI

struct SettingsView: View {
    @State private var searchText: String = ""
    @State private var selectedTab: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                searchBar
                tabSelector
                synthesisCard
                settingsSections
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Paramètres")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Rechercher un réglage...", text: $searchText)
                .font(.subheadline)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button {
                selectedTab = 0
            } label: {
                Text("Réglages unifiés")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selectedTab == 0 ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(selectedTab == 0 ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
            }
            Button {
                selectedTab = 1
            } label: {
                Text("Compte particulier")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selectedTab == 1 ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(selectedTab == 1 ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var synthesisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VUE SYNTHÈSE")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.8))
            Text("Réglages centraux, zone active et compte à jour")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Une seule page claire et dense pour piloter la carte, les notifications, les documents, la sécurité et l'assistance.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            HStack(spacing: 6) {
                synthStat(value: "2", label: "zones\nfavorites")
                synthStat(value: "2", label: "artisans\nsuivis")
                synthStat(value: "14", label: "alertes\nactives")
            }
            Button { } label: {
                Text("Voir la carte interactive maintenant")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ArtisgoTheme.orange)
                    .clipShape(.rect(cornerRadius: 12))
            }
            Button { } label: {
                Text("Changer ma zone")
                    .font(.subheadline.bold())
                    .foregroundStyle(ArtisgoTheme.darkBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white.opacity(0.9))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "4A90D9"), Color(hex: "357ABD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 18))
        .padding(.horizontal, 16)
    }

    private func synthStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10))
    }

    private var settingsSections: some View {
        VStack(spacing: 2) {
            settingsRow(icon: "person.crop.circle", title: "Mon compte", subtitle: "Photo, bannière, identité", badge: "CONFIGURABLE")
            settingsRow(icon: "mappin.circle", title: "Localisation", subtitle: "Zone active, rayon, favoris", badge: nil)
            settingsRow(icon: "bell", title: "Notifications", subtitle: "Alertes, fréquence, canaux", badge: nil)
            settingsRow(icon: "lock.shield", title: "Confidentialité", subtitle: "Visibilité, partage, données", badge: nil)
            settingsRow(icon: "doc.text", title: "Documents", subtitle: "Assurances, certifications, factures", badge: nil)
            settingsRow(icon: "shield.checkered", title: "Sécurité", subtitle: "Mot de passe, 2FA, sessions", badge: nil)
            settingsRow(icon: "creditcard", title: "Paiements", subtitle: "Moyens de paiement, historique", badge: nil)
            settingsRow(icon: "globe", title: "Langue", subtitle: "Français", badge: nil)
            settingsRow(icon: "externaldrive", title: "Données", subtitle: "Export, suppression, cache", badge: nil)
            settingsRow(icon: "info.circle", title: "À propos", subtitle: "Version, mentions légales", badge: nil)
            settingsRow(icon: "envelope", title: "Nous contacter", subtitle: "Support, suggestions", badge: nil)
        }
        .padding(.horizontal, 16)
    }

    private func settingsRow(icon: String, title: String, subtitle: String, badge: String?) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(ArtisgoTheme.orange.opacity(0.8))
                .frame(width: 36, height: 36)
                .background(ArtisgoTheme.orange.opacity(0.08))
                .clipShape(.rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(ArtisgoTheme.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(ArtisgoTheme.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
