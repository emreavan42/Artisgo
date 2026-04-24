import SwiftUI

struct InscriptionArtisanEtape2View: View {
    let etape1Data: ArtisanInscriptionData

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    @State private var nomEntreprise: String = ""
    @State private var siret: String = ""
    @State private var statutJuridique: String = ""
    @State private var metierPrincipal: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
    @State private var acceptCGU: Bool = false

    @State private var siretError: String = ""
    @State private var cpError: String = ""
    @State private var showSuccess: Bool = false

    @FocusState private var focus: Field?
    enum Field { case nom, siret, ville, cp }

    private var isValidCP: Bool {
        codePostal.filter(\.isNumber).count == 5
    }

    private let statuts = [
        "Auto-entrepreneur / Micro-entreprise",
        "Entreprise Individuelle (EI)",
        "EURL",
        "SARL",
        "SAS / SASU",
        "Autre"
    ]

    private let metiers = [
        "Peinture", "Électricité", "Plomberie", "Carrelage",
        "Placo / Plâtrerie", "Maçonnerie", "Menuiserie",
        "Chauffage / Climatisation", "Salle de bain", "Cuisine",
        "Toiture", "Serrurerie", "Vitrerie", "Parquet", "Isolation",
        "Jardinage / Paysagisme", "Piscine", "Déménagement",
        "Nettoyage", "Multi-services", "Autre"
    ]

    private var isSiretValid: Bool {
        let digits = siret.filter(\.isNumber)
        return digits.count == 14
    }

    private var isValid: Bool {
        !nomEntreprise.isEmpty && isSiretValid &&
        !statutJuridique.isEmpty && !metierPrincipal.isEmpty &&
        !ville.isEmpty && isValidCP && acceptCGU
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Votre entreprise")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Étape 2 sur 2 — Informations professionnelles")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ArtisgoTheme.orange)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ArtisgoTheme.orange)
                            .frame(height: 6)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 8)

                ArtisgoFormField(label: "Nom de l'entreprise") {
                    TextField("", text: $nomEntreprise)
                        .focused($focus, equals: .nom)
                        .artisgoField(isFocused: focus == .nom)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ArtisgoFormField(label: "SIRET", error: siretError) {
                        TextField("", text: $siret)
                            .focused($focus, equals: .siret)
                            .keyboardType(.numberPad)
                            .artisgoField(isFocused: focus == .siret, hasError: !siretError.isEmpty)
                    }
                    Text("14 chiffres, visible sur votre Kbis ou avis de situation")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .onChange(of: focus) { old, _ in
                    if old == .siret {
                        siretError = (siret.isEmpty || isSiretValid) ? "" : "SIRET invalide (14 chiffres)"
                    }
                }

                ArtisgoFormField(label: "Statut juridique") {
                    Menu {
                        ForEach(statuts, id: \.self) { option in
                            Button(option) { statutJuridique = option }
                        }
                    } label: {
                        HStack {
                            Text(statutJuridique.isEmpty ? "Sélectionner" : statutJuridique)
                                .foregroundStyle(statutJuridique.isEmpty ? Color.secondary : Color.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .artisgoField(isFocused: false)
                    }
                }

                ArtisgoFormField(label: "Métier principal") {
                    Menu {
                        ForEach(metiers, id: \.self) { option in
                            Button(option) { metierPrincipal = option }
                        }
                    } label: {
                        HStack {
                            Text(metierPrincipal.isEmpty ? "Sélectionner" : metierPrincipal)
                                .foregroundStyle(metierPrincipal.isEmpty ? Color.secondary : Color.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .artisgoField(isFocused: false)
                    }
                }

                ArtisgoFormField(label: "Ville") {
                    TextField("", text: $ville)
                        .focused($focus, equals: .ville)
                        .artisgoField(isFocused: focus == .ville)
                }

                VStack(alignment: .leading, spacing: 4) {
                    ArtisgoFormField(label: "Code postal", error: cpError) {
                        TextField("42000", text: $codePostal)
                            .focused($focus, equals: .cp)
                            .keyboardType(.numberPad)
                            .artisgoField(isFocused: focus == .cp, hasError: !cpError.isEmpty)
                            .onChange(of: codePostal) { _, newValue in
                                let filtered = String(newValue.filter { $0.isNumber }.prefix(5))
                                if filtered != newValue { codePostal = filtered }
                            }
                    }
                    Text("Le code postal de votre commune")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .onChange(of: focus) { old, _ in
                    if old == .cp {
                        cpError = (codePostal.isEmpty || isValidCP) ? "" : "Code postal invalide (5 chiffres)"
                    }
                }

                CGUToggle(isOn: $acceptCGU)
                    .padding(.top, 4)

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(ArtisgoTheme.darkBlue)
                        .font(.system(size: 18))
                    Text("Pour accepter votre premier chantier, vous devrez compléter votre profil avec votre assurance décennale et votre RC Pro.")
                        .font(.system(size: 13))
                        .foregroundStyle(ArtisgoTheme.darkBlue)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ArtisgoTheme.lightBlue, in: .rect(cornerRadius: 12))

                PrimaryOrangeButton(title: "Créer mon compte", isEnabled: isValid) {
                    print("Inscription artisan: \(etape1Data.prenom) \(etape1Data.nom) — \(nomEntreprise) / SIRET \(siret) / \(statutJuridique) / \(metierPrincipal) / \(ville)")
                    showSuccess = true
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Bienvenue \(etape1Data.prenom) !", isPresented: $showSuccess) {
            Button("OK") {
                isLoggedIn = true
            }
        } message: {
            Text("Votre compte artisan a été créé avec succès.")
        }
    }
}

#Preview {
    NavigationStack {
        InscriptionArtisanEtape2View(etape1Data: ArtisanInscriptionData())
    }
}
