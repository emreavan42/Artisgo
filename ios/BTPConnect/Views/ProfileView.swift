import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var showSettings: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    documentsSection
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button { } label: {
                    Text("TABLEAU DE BORD")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                Spacer()
                Button { showSettings = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption)
                        Text("Paramètres")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ArtigoTheme.orange)
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "person.crop.rectangle")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sophie Martin")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Compte particulier · Chantier Écully")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Gère ta zone, tes documents, tes alertes et tous tes paramètres depuis un seul espace plus clair et plus fiable.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(3)
                }
            }

            HStack(spacing: 0) {
                profileStat(value: "12", label: "Contacts")
                profileStat(value: "5", label: "Devis actifs")
                profileStat(value: "4,9", label: "Avis\nmoyens")
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [ArtigoTheme.orange, ArtigoTheme.orange.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10))
    }

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mes Documents")
                    .font(.title3.bold())
                Spacer()
                Text("Organisé")
                    .font(.caption.bold())
                    .foregroundStyle(ArtigoTheme.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule().stroke(ArtigoTheme.orange, lineWidth: 1)
                    )
            }

            Text("Assurances, certifications avec dates d'expiration, factures PDF, devis archivés, contrats et portfolio.")
                .font(.caption)
                .foregroundStyle(.secondary)

            let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                documentCard(icon: "checkmark.shield.fill", title: "Assurances", subtitle: "Décennale, RC pro, échéances", count: "2 documents actifs", color: ArtigoTheme.orange)
                documentCard(icon: "rosette", title: "Certifications", subtitle: "RGE, Qualibat, labels", count: "4 justificatifs suivis", color: ArtigoTheme.orange)
                documentCard(icon: "doc.text.fill", title: "Factures PDF", subtitle: "Historique complet", count: "", color: .secondary)
                documentCard(icon: "slider.horizontal.3", title: "Devis archivés", subtitle: "Suivi et comparaison", count: "", color: .secondary)
            }
        }
        .padding(.horizontal, 16)
    }

    private func documentCard(icon: String, title: String, subtitle: String, count: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            if !count.isEmpty {
                Text(count)
                    .font(.caption2.bold())
                    .foregroundStyle(ArtigoTheme.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }
}
