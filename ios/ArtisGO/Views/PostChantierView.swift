import SwiftUI

struct PostChantierView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String?
    @State private var searchText: String = ""
    @State private var currentStep: Int = 1
    @State private var description: String = ""
    @State private var budget: String = ""
    @State private var location: String = ""
    @State private var isUrgent: Bool = false

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
        VStack(alignment: .leading, spacing: 14) {
            Text("3. Localisation du chantier")
                .font(.headline)

            HStack(spacing: 10) {
                Image(systemName: "mappin")
                    .foregroundStyle(.secondary)
                TextField("Adresse ou ville...", text: $location)
                    .font(.subheadline)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
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
                confirmRow(label: "Localisation", value: location.isEmpty ? "Non défini" : location)
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
