import SwiftUI
import CoreLocation

struct PostChantierView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String?
    @State private var searchText: String = ""
    @State private var currentStep: Int = 1
    @State private var description: String = ""
    @State private var budget: String = ""
    @State private var location: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var isUrgent: Bool = false
    @State private var locationService = LocationService()
    @State private var locationErrorMessage: String? = nil
    @State private var isFetchingLocation: Bool = false
    @State private var citySuggestions: [GeocodedPlace] = []
    @State private var searchTask: Task<Void, Never>? = nil

    private let totalSteps = 5

    var filteredCategories: [String] {
        if searchText.isEmpty { return SampleData.chantierCategories }
        return SampleData.chantierCategories.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerCard
                    progressBar

                    switch currentStep {
                    case 1: categoryStep
                    case 2: descriptionStep
                    case 3: locationStep
                    case 4: budgetStep
                    default: confirmStep
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Publier un chantier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    if currentStep > 1 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Text("Retour")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    Button {
                        if currentStep < totalSteps {
                            withAnimation { currentStep += 1 }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text(currentStep == totalSteps ? "Publier" : "Suivant")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ArtisgoTheme.orange)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.bar)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ÉTAPE PAR ÉTAPE")
                .font(.caption.bold())
                .foregroundStyle(ArtisgoTheme.orange)
            Text("Décrivez votre besoin avec précision")
                .font(.title3.bold())
            Text("Un formulaire riche, pensé pour rester lisible sur mobile et prêt à être branché au backend plus tard.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.green : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
    }

    private var categoryStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("1. Catégorie principale de travaux")
                .font(.headline)

            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.secondary)
                TextField("Rechercher un type de chantier...", text: $searchText)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))

            ForEach(filteredCategories, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category)
                        .font(.subheadline)
                        .foregroundStyle(selectedCategory == category ? ArtisgoTheme.orange : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(selectedCategory == category ? ArtisgoTheme.orange : Color.clear, lineWidth: 1.5)
                        )
                }
            }
        }
    }

    private var descriptionStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("2. Décrivez votre projet")
                .font(.headline)

            TextEditor(text: $description)
                .font(.subheadline)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))

            Toggle(isOn: $isUrgent) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(ArtisgoTheme.orange)
                    Text("Chantier urgent")
                        .font(.subheadline)
                }
            }
            .tint(ArtisgoTheme.orange)
        }
    }

    private var locationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Où se trouve le chantier ?")
                .font(.headline)

            // Bouton GPS
            Button {
                Task { await useCurrentLocation() }
            } label: {
                HStack(spacing: 10) {
                    if isFetchingLocation {
                        ProgressView()
                    } else {
                        Image(systemName: "location.fill")
                    }
                    Text(isFetchingLocation ? "Localisation..." : "Utiliser ma position")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(ArtisgoTheme.darkBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ArtisgoTheme.darkBlue, lineWidth: 1.5)
                )
            }
            .disabled(isFetchingLocation)

            if let err = locationErrorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // Séparateur "ou"
            HStack(spacing: 12) {
                Rectangle().fill(Color(.systemGray4)).frame(height: 1)
                Text("ou").font(.caption).foregroundStyle(.secondary)
                Rectangle().fill(Color(.systemGray4)).frame(height: 1)
            }

            // Champ ville avec autocomplete
            VStack(alignment: .leading, spacing: 6) {
                Text("Ville *")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                TextField("Ex: Saint-Étienne", text: $ville)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                    .onChange(of: ville) { _, newValue in
                        scheduleCitySearch(newValue)
                    }

                if !citySuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(citySuggestions.prefix(5)) { place in
                            Button {
                                selectSuggestion(place)
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(ArtisgoTheme.orange)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(place.ville).font(.subheadline).foregroundStyle(.primary)
                                        if !place.codePostal.isEmpty {
                                            Text(place.codePostal).font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            if place.id != citySuggestions.prefix(5).last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
            }

            // Code postal
            VStack(alignment: .leading, spacing: 6) {
                Text("Code postal *")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                TextField("42000", text: $codePostal)
                    .font(.subheadline)
                    .keyboardType(.numberPad)
                    .onChange(of: codePostal) { _, newValue in
                        let filtered = String(newValue.filter { $0.isNumber }.prefix(5))
                        if filtered != newValue { codePostal = filtered }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    // Utilise la position GPS actuelle
    private func useCurrentLocation() async {
        isFetchingLocation = true
        locationErrorMessage = nil
        defer { isFetchingLocation = false }
        do {
            let loc = try await locationService.requestCurrentLocation()
            let place = try await locationService.reverseGeocode(loc)
            ville = place.ville
            codePostal = place.codePostal
            latitude = loc.coordinate.latitude
            longitude = loc.coordinate.longitude
            citySuggestions = []
        } catch LocationError.denied {
            locationErrorMessage = "Autorisez la localisation dans Réglages, ou tapez votre ville manuellement."
        } catch {
            locationErrorMessage = "Impossible de récupérer la position. Tapez votre ville manuellement."
        }
    }

    // Recherche asynchrone de villes (debounce 300ms)
    private func scheduleCitySearch(_ query: String) {
        searchTask?.cancel()
        guard query.count >= 2 else {
            citySuggestions = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            let results = (try? await locationService.searchCities(query)) ?? []
            if Task.isCancelled { return }
            citySuggestions = results
        }
    }

    private func selectSuggestion(_ place: GeocodedPlace) {
        ville = place.ville
        codePostal = place.codePostal
        latitude = place.coordinate.latitude
        longitude = place.coordinate.longitude
        citySuggestions = []
    }

    private var budgetStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("4. Budget estimé")
                .font(.headline)

            HStack(spacing: 10) {
                Image(systemName: "eurosign.circle")
                    .foregroundStyle(.secondary)
                TextField("Ex: 5000 - 10000 €", text: $budget)
                    .font(.subheadline)
                    .keyboardType(.default)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var confirmStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("5. Confirmation")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                confirmRow(label: "Catégorie", value: selectedCategory ?? "Non défini")
                confirmRow(label: "Description", value: description.isEmpty ? "Non défini" : description)
                confirmRow(label: "Localisation", value: ville.isEmpty ? "Non défini" : "\(ville) \(codePostal)")
                confirmRow(label: "Budget", value: budget.isEmpty ? "Non défini" : budget)
                confirmRow(label: "Urgent", value: isUrgent ? "Oui" : "Non")
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func confirmRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}
