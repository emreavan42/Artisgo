import SwiftUI

struct ArtisanDetailSheet: View {
    let artisan: Artisan

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 56, height: 56)
                    Text(String(artisan.name.prefix(1)))
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(artisan.name)
                        .font(.headline)
                    Text(artisan.profession)
                        .font(.subheadline)
                        .foregroundStyle(ArtigoTheme.orange)
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            Text("\(artisan.rating, specifier: "%.1f")")
                                .font(.caption.bold())
                        }
                        Text("\(artisan.distance, specifier: "%.1f") km")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("À partir de \(artisan.pricePerSqm) €/m²")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            Text(artisan.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if artisan.isAvailable {
                    Label("Disponible", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
                if artisan.isUrgent {
                    Label("Urgent", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(ArtigoTheme.orange)
                }
            }

            HStack(spacing: 12) {
                Button { } label: {
                    Text("Voir la fiche")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
                Button { } label: {
                    Text("Contacter")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ArtigoTheme.orange)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
        .padding(20)
    }
}
