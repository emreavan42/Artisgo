import SwiftUI
import MapKit

struct SearchView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var searchText: String = ""
    @State private var selectedArtisan: Artisan?
    @State private var showFilters: Bool = false
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
                    VStack(spacing: 16) {
                        statsBar
                        searchBar
                        filterChips
                        viewModeSelector
                        categorySelector
                        distanceSlider
                        ratingFilters
                        mapSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(ArtigoTheme.lightBlue)
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
                Text("Vue quartier")
                    .font(.title2.bold())
                Text("Pins interactifs, urgences visuelles et accès direct aux artisans proches.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { showFilters.toggle() } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(ArtigoTheme.lightBlue)
    }

    private var statsBar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.filteredArtisans.count)")
                    .font(.title3.bold())
                Text("artisans\nvisibles")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.chantiers.count)")
                    .font(.title3.bold())
                Text("chantiers\nvisibles")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("2")
                    .font(.title3.bold())
                    .foregroundStyle(ArtigoTheme.orange)
                Text("zones\nfavorites")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
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
                            .background(viewModel.selectedMapFilter == filter ? ArtigoTheme.orange : Color(.secondarySystemGroupedBackground))
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
                    viewMode = mode
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
                    .background(viewMode == mode ? ArtigoTheme.orange : Color.clear)
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
                                .foregroundStyle(viewModel.selectedCategory == cat ? ArtigoTheme.orange : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedCategory == cat ? ArtigoTheme.orange.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(viewModel.selectedCategory == cat ? ArtigoTheme.orange : Color.clear, lineWidth: 1)
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
                    Text("\(rating, specifier: "%.1f")+")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(viewModel.selectedRatingFilter == rating ? ArtigoTheme.orange : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedRatingFilter == rating ? ArtigoTheme.orange.opacity(0.12) : Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(viewModel.selectedRatingFilter == rating ? ArtigoTheme.orange : Color.clear, lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var mapSection: some View {
        VStack(spacing: 0) {
            Map(position: $mapPosition, interactionModes: .all) {
                ForEach(viewModel.filteredArtisans) { artisan in
                    Annotation(artisan.name, coordinate: artisan.coordinate) {
                        Button {
                            selectedArtisan = artisan
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(artisan.isUrgent ? ArtigoTheme.orange : .blue)
                                .background(Circle().fill(.white).padding(-2))
                        }
                    }
                }
            }
            .mapStyle(viewMode == .satellite ? .imagery : .standard)
            .frame(height: 350)
            .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))

            if let artisan = selectedArtisan {
                artisanPreviewCard(artisan)
            }
        }
        .padding(.horizontal, 16)
    }

    private func artisanPreviewCard(_ artisan: Artisan) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(artisan.name)
                        .font(.headline)
                    Text(artisan.profession)
                        .font(.subheadline)
                        .foregroundStyle(ArtigoTheme.orange)
                    Text("\(artisan.distance, specifier: "%.1f") km · À partir de \(artisan.pricePerSqm) €/m²")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text("\(artisan.rating, specifier: "%.1f")")
                        .font(.subheadline.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
            }

            Text(artisan.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 12) {
                Button { } label: {
                    Text("Voir la fiche")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                }
                Button { } label: {
                    Text("Contacter")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(ArtigoTheme.orange)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: ArtigoTheme.cornerRadius))
    }
}
