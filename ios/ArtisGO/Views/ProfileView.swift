import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var showSettings: Bool = false
    @State private var showClassement: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    statsRow
                    documentsSection
                    classementButton
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showClassement) {
                ClassementView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    ArtisgoLogoView(size: 28)
                    Text("Mon Profil")
                        .font(.title2.bold())
                }
                Spacer()
                Button { showSettings = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill")
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
            .padding(.horizontal, 16)
            .padding(.top, 8)

            VStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient(colors: [ArtisgoTheme.orange.opacity(0.3), ArtisgoTheme.orange.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 90, height: 90)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(ArtisgoTheme.orange.opacity(0.6))
                        }
                    Button { } label: {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(ArtigoTheme.orange)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                    }
                }

                VStack(spacing: 4) {
                    Text("Sophie Martin")
                        .font(.title3.bold())
                    Text("Compte particulier · Chantier Écully")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Gère ta zone, tes documents, tes alertes et tous tes paramètres depuis un seul espace.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            profileStatCard(value: "12", label: "Contacts", icon: "person.2.fill")
            profileStatCard(value: "5", label: "Devis actifs", icon: "doc.text.fill")
            profileStatCard(value: "4,9", label: "Avis moyens", icon: "star.fill")
        }
        .padding(.horizontal, 16)
    }

    private func profileStatCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(ArtisgoTheme.orange)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
    }

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mes Documents")
                    .font(.title3.bold())
                Spacer()
                Text("Organisé")
                    .font(.caption.bold())
                    .foregroundStyle(ArtisgoTheme.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule().stroke(ArtisgoTheme.orange, lineWidth: 1)
                    )
            }

            let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
            LazyVGrid(columns: columns, spacing: 10) {
                documentCard(icon: "checkmark.shield.fill", title: "Assurances", subtitle: "Décennale, RC pro", count: "2 actifs", color: ArtisgoTheme.orange)
                documentCard(icon: "rosette", title: "Certifications", subtitle: "RGE, Qualibat", count: "4 suivis", color: ArtisgoTheme.orange)
                documentCard(icon: "doc.text.fill", title: "Factures PDF", subtitle: "Historique complet", count: "", color: .blue)
                documentCard(icon: "archivebox.fill", title: "Devis archivés", subtitle: "Suivi et comparaison", count: "", color: .secondary)
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
                    .foregroundStyle(ArtisgoTheme.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }

    private var classementButton: some View {
        Button { showClassement = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.title3)
                    .foregroundStyle(ArtisgoTheme.orange)
                    .frame(width: 44, height: 44)
                    .background(ArtisgoTheme.orange.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Classement du mois")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Voir le top artisans par métier et notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}
