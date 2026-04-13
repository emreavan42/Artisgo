import SwiftUI

struct FavoritesView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var favoriteArtisans: [Artisan] = Array(SampleData.artisans.prefix(3))

    var body: some View {
        NavigationStack {
            ScrollView {
                if favoriteArtisans.isEmpty {
                    ContentUnavailableView("Aucun favori", systemImage: "heart.slash", description: Text("Ajoutez des artisans à vos favoris pour les retrouver ici."))
                        .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteArtisans) { artisan in
                            FavoriteArtisanCard(artisan: artisan) {
                                withAnimation {
                                    favoriteArtisans.removeAll { $0.id == artisan.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Favoris")
        }
    }
}

struct FavoriteArtisanCard: View {
    let artisan: Artisan
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 52, height: 52)
                Text(String(artisan.name.prefix(1)))
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(artisan.name)
                    .font(.headline)
                Text(artisan.profession)
                    .font(.caption)
                    .foregroundStyle(ArtigoTheme.orange)
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(artisan.rating, specifier: "%.1f")")
                            .font(.caption)
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(artisan.distance, specifier: "%.1f") km")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button { onRemove() } label: {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }
}
