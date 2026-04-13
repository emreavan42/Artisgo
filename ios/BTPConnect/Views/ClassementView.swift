import SwiftUI

struct ClassementView: View {
    @Environment(AppViewModel.self) private var viewModel

    private let topArtisans: [(rank: Int, name: String, profession: String, rating: Double, projects: Int)] = [
        (1, "Julien Mercier", "Salle de bain", 4.9, 24),
        (2, "Marc Leroy", "Plomberie", 4.8, 18),
        (3, "Nicolas R", "Électricité", 4.7, 15),
        (4, "Sophie Carrelage", "Carrelage & Faïence", 4.6, 12),
        (5, "BTP Durand & Fils", "Rénovation globale", 4.5, 22)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    ForEach(topArtisans, id: \.rank) { artisan in
                        rankRow(artisan)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Classement du mois")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
            Text("Top artisans")
                .font(.title3.bold())
            Text("Classement basé sur les notes clients et le nombre de projets réalisés ce mois-ci.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [ArtigoTheme.orange.opacity(0.15), ArtigoTheme.orange.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }

    private func rankRow(_ artisan: (rank: Int, name: String, profession: String, rating: Double, projects: Int)) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(artisan.rank <= 3 ? ArtigoTheme.orange : Color(.systemGray4))
                    .frame(width: 36, height: 36)
                Text("\(artisan.rank)")
                    .font(.headline)
                    .foregroundStyle(artisan.rank <= 3 ? .white : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(artisan.name)
                    .font(.headline)
                Text(artisan.profession)
                    .font(.caption)
                    .foregroundStyle(ArtigoTheme.orange)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("\(artisan.rating, specifier: "%.1f")")
                        .font(.subheadline.bold())
                }
                Text("\(artisan.projects) projets")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }
}
