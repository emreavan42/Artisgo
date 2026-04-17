import SwiftUI
import MapKit

struct SearchView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText: String = ""
    @State private var selectedArtisan: Artisan?
    @State private var viewMode: ViewMode = .map
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.7780, longitude: 4.8060),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    enum ViewMode: String, CaseIterable {
        case map = "Vue quartier"
        case list = "Vue liste"
        case satellite = "Vue satellite"

        var icon: String {
            switch self {
            case .map: return "mappin.and.ellipse"
            case .list: return "list.bullet"
            case .satellite: return "globe.americas"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                ScrollView {
                    VStack(spacing: 14) {
                        statsBar
                        searchBar
                        filterChips
                        viewModeSelector
                        categorySelector
                        distanceSlider
                        ratingFilters

                        switch viewMode {
                        case .map, .satellite:
                            mapSection
                        case .list:
                            listSection
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(item: $selectedArtisan) { artisan in
                ArtisanDetailSheet(artisan: artisan)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    ArtisgoLogoView(size: 28)
                    Text("Vue quartier")
                        .font(.title2.bold())
                }
                Text("Pins interactifs, urgences visuelles et accès direct aux artisans proches.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var statsBar: some View {
        HStack(spacing: 8) {
            statBadge(value: "\(viewModel.filteredArtisans.count)", label: "artisans\nvisibles", color: .primary)
            statBadge(value: "\(viewModel.chantiers.count)", label: "chantiers\nvisibles", color: .primary)
            statBadge(value: "2", label: "zones\nfavorites", color: ArtisgoTheme.orange)
        }
        .padding(.horizontal, 16)
    }

    private func statBadge(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Rechercher une adresse, un artisan ou...", text: $searchText)
                .font(.subheadline)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var filterChips: some View {
        let filters = ["Mixte", "Pros", "Chantiers", "Urgent", "Disponibles"]
        return ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        viewModel.selectedMapFilter = filter
                    } label: {
                        Text(filter)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(viewModel.selectedMapFilter == filter ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedMapFilter == filter ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(viewMode == mode ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewMode == mode ? ArtisgoTheme.orange : Color.clear)
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Métier / catégorie")
                .font(.subheadline.bold())
                .padding(.leading, 16)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(SampleData.tradeCategories, id: \.self) { cat in
                        Button {
                            viewModel.selectedCategory = cat
                        } label: {
                            Text(cat)
                                .font(.caption)
                                .foregroundStyle(viewModel.selectedCategory == cat ? ArtisgoTheme.orange : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedCategory == cat ? ArtisgoTheme.orange.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(viewModel.selectedCategory == cat ? ArtisgoTheme.orange : Color.clear, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
    }

    private var distanceSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Distance maximale")
                .font(.subheadline.bold())
                .padding(.leading, 16)
            DistanceSliderView(selectedRadius: Binding(
                get: { viewModel.currentRadius },
                set: { viewModel.currentRadius = $0 }
            ))
            .padding(.horizontal, 16)
        }
    }

    private var ratingFilters: some View {
        HStack(spacing: 10) {
            ForEach([4.1, 4.4, 4.7], id: \.self) { rating in
                Button {
                    if viewModel.selectedRatingFilter == rating {
                        viewModel.selectedRatingFilter = nil
                    } else {
                        viewModel.selectedRatingFilter = rating
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(rating, specifier: "%.1f")+")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(viewModel.selectedRatingFilter == rating ? ArtisgoTheme.orange : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedRatingFilter == rating ? ArtisgoTheme.orange.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(viewModel.selectedRatingFilter == rating ? ArtisgoTheme.orange : Color.clear, lineWidth: 1)
                    )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var mapSection: some View {
        Map(position: $mapPosition, interactionModes: .all) {
            ForEach(viewModel.filteredArtisans) { artisan in
                Annotation(artisan.name, coordinate: artisan.coordinate) {
                    Button {
                        selectedArtisan = artisan
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(artisan.isUrgent ? ArtisgoTheme.orange : .blue)
                            .background(Circle().fill(Color(.systemBackground)).padding(-2))
                    }
                }
            }
        }
        .mapStyle(viewMode == .satellite ? .imagery : .standard)
        .frame(height: 350)
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
        .padding(.horizontal, 16)
    }

    private var listSection: some View {
        LazyVStack(spacing: 10) {
            let sorted = viewModel.filteredArtisans.sorted { $0.distance < $1.distance }
            ForEach(sorted) { artisan in
                Button {
                    selectedArtisan = artisan
                } label: {
                    listRow(artisan)
                }
                .buttonStyle(.plain)
            }

            if viewModel.filteredArtisans.isEmpty {
                ContentUnavailableView(
                    "Aucun résultat",
                    systemImage: "magnifyingglass",
                    description: Text("Essayez d'élargir votre rayon de recherche ou modifiez les filtres.")
                )
                .padding(.top, 40)
            }
        }
        .padding(.horizontal, 16)
    }

    private func listRow(_ artisan: Artisan) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 56, height: 56)
                Text(String(artisan.name.prefix(1)))
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(artisan.name)
                        .font(.headline)
                    if artisan.isUrgent {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(ArtisgoTheme.orange)
                    }
                }
                Text(artisan.profession)
                    .font(.subheadline)
                    .foregroundStyle(ArtisgoTheme.orange)
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(artisan.rating, specifier: "%.1f")")
                            .font(.caption.bold())
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(artisan.distance, specifier: "%.1f") km")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("~\(artisan.pricePerSqm) €/m²")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { } label: {
                Text("Contacter")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ArtisgoTheme.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: ArtisgoTheme.cornerRadius))
    }
}
