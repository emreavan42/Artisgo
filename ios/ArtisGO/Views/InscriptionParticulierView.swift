import SwiftUI

struct InscriptionParticulierView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var prenom: String = ""
    @State private var nom: String = ""
    @State private var email: String = ""
    @State private var telephone: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
    @State private var motDePasse: String = ""
    @State private var acceptCGU: Bool = false

    @State private var emailError: String = ""
    @State private var telError: String = ""
    @State private var mdpError: String = ""
    @State private var cpError: String = ""

    @State private var showSuccess: Bool = false

    @State private var locationService = LocationService()
    @State private var isFetchingLocation: Bool = false
    @State private var locationErrorMessage: String? = nil

    @FocusState private var focus: Field?
    enum Field { case prenom, nom, email, tel, ville, cp, mdp }

    private var isValidCP: Bool {
        codePostal.filter(\.isNumber).count == 5
    }

    private var isValid: Bool {
        !prenom.isEmpty && !nom.isEmpty &&
        isValidEmail(email) && isValidPhone(telephone) &&
        !ville.isEmpty && isValidCP && motDePasse.count >= 8 && acceptCGU
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bienvenue !")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Créez votre compte en 30 secondes")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                ArtisgoFormField(label: "Prénom") {
                    TextField("", text: $prenom)
                        .focused($focus, equals: .prenom)
                        .artisgoField(isFocused: focus == .prenom)
                }

                ArtisgoFormField(label: "Nom") {
                    TextField("", text: $nom)
                        .focused($focus, equals: .nom)
                        .artisgoField(isFocused: focus == .nom)
                }

                ArtisgoFormField(label: "Email", error: emailError) {
                    TextField("", text: $email)
                        .focused($focus, equals: .email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .artisgoField(isFocused: focus == .email, hasError: !emailError.isEmpty)
                }
                .onChange(of: focus) { old, _ in
                    if old == .email {
                        emailError = (email.isEmpty || isValidEmail(email)) ? "" : "Email invalide"
                    }
                }

                ArtisgoFormField(label: "Téléphone", error: telError) {
                    TextField("", text: $telephone)
                        .focused($focus, equals: .tel)
                        .keyboardType(.phonePad)
                        .artisgoField(isFocused: focus == .tel, hasError: !telError.isEmpty)
                }
                .onChange(of: focus) { old, _ in
                    if old == .tel {
                        telError = (telephone.isEmpty || isValidPhone(telephone)) ? "" : "Téléphone invalide (10 chiffres)"
                    }
                }

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

                ArtisgoFormField(label: "Mot de passe", error: mdpError) {
                    SecureField("", text: $motDePasse)
                        .focused($focus, equals: .mdp)
                        .artisgoField(isFocused: focus == .mdp, hasError: !mdpError.isEmpty)
                }
                .onChange(of: focus) { old, _ in
                    if old == .mdp {
                        mdpError = (motDePasse.isEmpty || motDePasse.count >= 8) ? "" : "Minimum 8 caractères"
                    }
                }

                CGUToggle(isOn: $acceptCGU)
                    .padding(.top, 4)

                PrimaryOrangeButton(title: "Créer mon compte", isEnabled: isValid) {
                    print("Inscription particulier: \(prenom) \(nom) / \(email) / \(telephone) / \(ville) \(codePostal)")
                    showSuccess = true
                }
                .padding(.top, 8)

                HStack(spacing: 4) {
                    Text("Déjà un compte ?").foregroundStyle(.secondary)
                    NavigationLink("Se connecter") { ConnexionView() }
                        .foregroundStyle(ArtisgoTheme.orange)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Bienvenue \(prenom) !", isPresented: $showSuccess) {
            Button("OK") {
                isLoggedIn = true
            }
        } message: {
            Text("Votre compte a été créé avec succès.")
        }
    }
}

extension InscriptionParticulierView {
    func useCurrentLocation() async {
        isFetchingLocation = true
        locationErrorMessage = nil
        defer { isFetchingLocation = false }
        do {
            let loc = try await locationService.requestCurrentLocation()
            let place = try await locationService.reverseGeocode(loc)
            ville = place.ville
            codePostal = place.codePostal
        } catch LocationError.denied {
            locationErrorMessage = "Autorisez la localisation dans Réglages, ou tapez votre ville manuellement."
        } catch {
            locationErrorMessage = "Impossible de récupérer la position."
        }
    }
}

func isValidEmail(_ s: String) -> Bool {
    s.contains("@") && s.contains(".") && s.count >= 5
}

func isValidPhone(_ s: String) -> Bool {
    let digits = s.filter(\.isNumber)
    return digits.count == 10
}

#Preview {
    NavigationStack { InscriptionParticulierView() }
}
