import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText: String = ""
    @State private var showPostChantier: Bool = false
    @State private var showNotifications: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    searchBar
                    chantierCard
                    featuredCardsSection
                    quickFilters
                    postButton
                    discoverySection
                    statsSection
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showPostChantier) {
                PostChantierView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                ArtisgoLogoView(size: 34)
                Text("Artisgo")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button { showNotifications = true } label: {
                Image(systemName: "bell.fill")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 42, height: 42)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        let unreadCount = viewModel.notifications.filter({ !$0.isRead }).count
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 18, height: 18)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text("Rechercher un métier, une spécialité, un chantier...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "slider.horizontal.3")
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 8))
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var chantierCard: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(ArtisgoTheme.orange.opacity(0.7))
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("Chantier \(viewModel.currentLocation)")
                    .font(.headline)
                Text("\(viewModel.currentRadius) km · modifier la zone")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                viewModel.selectedTab = .search
            } label: {
                HStack(spacing: 4) {
                    Text("Voir sur carte")
                        .font(.subheadline.bold())
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(ArtisgoTheme.orange)
                .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
        .padding(.horizontal, 16)
    }

    private var featuredCardsSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                urgentCard
                bestArtisansCard
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var urgentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
                .padding(10)
                .background(.white.opacity(0.2))
                .clipShape(Circle())

            Text("Chantiers urgents près de moi")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Fuites, pannes, sécurisation et demandes express visibles en priorité.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: 4) {
                Text("Voir les urgences")
                    .font(.subheadline.bold())
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .frame(width: 300, alignment: .leading)
        .background(
            LinearGradient(
                colors: [ArtisgoTheme.orange, ArtisgoTheme.orange.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
    }

    private var bestArtisansCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
                .padding(10)
                .background(.white.opacity(0.2))
                .clipShape(Circle())

            Text("Meilleurs artisans de la semaine")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Profils vérifiés, notés 4.7+ et disponibles.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: 4) {
                Text("Comparer")
                    .font(.subheadline.bold())
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
            }
            .foregroundStyle(.white)
        }
        .padding(20)
        .frame(width: 300, alignment: .leading)
        .background(
            LinearGradient(
                colors: [ArtisgoTheme.darkBlue, Color(hex: "2A5D8F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
    }

    private var quickFilters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                filterChip("Chantiers urgents", icon: "exclamationmark.triangle.fill")
                filterChip("Artisans disponibles aujourd'hui", icon: "checkmark.circle.fill")
                filterChip("Moins de 10 km", icon: "location.fill")
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private func filterChip(_ text: String, icon: String) -> some View {
        Button { } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(ArtisgoTheme.orange)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
        }
    }

    private var postButton: some View {
        Button { showPostChantier = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Poster mon chantier")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ArtisgoTheme.orange)
            .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
        }
        .padding(.horizontal, 16)
    }

    private var discoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DÉCOUVERTE LOCALE")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.8))

            Text("Un accueil plus clair, plus utile et plus actionable.")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Comparez profils, urgences, certifications et disponibilité depuis une zone configurable.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [ArtisgoTheme.darkBlue, Color(hex: "2A5D8F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
        .padding(.horizontal, 16)
    }

    private var statsSection: some View {
        HStack(spacing: 8) {
            statItem(value: "143", label: "métiers BTP\nréférencés", highlighted: false)
            statItem(value: "143", label: "spécialités\nfiltrables", highlighted: true)
            statItem(value: "3", label: "chantiers\ncompatibles", highlighted: false)
        }
        .padding(.horizontal, 16)
    }

    private func statItem(value: String, label: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(ArtisgoTheme.orange)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}
