import SwiftUI
import MapKit

// MARK: - Écran "Envoyer mon adresse" avec carte interactive
struct EnvoyerAdresseView: View {
    @Environment(\.dismiss) private var dismiss
    let onSend: (String, CLLocationCoordinate2D) -> Void

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.4397, longitude: 4.3872), // Saint-Étienne
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var pinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 45.4397, longitude: 4.3872)
    @State private var addressText: String = "Tapez sur la carte pour placer le point"
    @State private var isGeocoding: Bool = false
    @State private var locationService = LocationService()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Carte interactive
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        Annotation("", coordinate: pinCoordinate) {
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.red)
                                    .background(Circle().fill(.white).frame(width: 24, height: 24))
                                    .shadow(radius: 3)
                            }
                        }
                    }
                    .onTapGesture { screenPoint in
                        if let coord = proxy.convert(screenPoint, from: .local) {
                            pinCoordinate = coord
                            Task { await reverseGeocode(coord) }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)

                // Bas : adresse + bouton envoyer
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(ArtisgoTheme.orange)
                            Text("Adresse")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            if isGeocoding {
                                ProgressView().scaleEffect(0.7)
                            }
                            Spacer()
                        }
                        TextField("Adresse", text: $addressText, axis: .vertical)
                            .font(.subheadline)
                            .lineLimit(2...3)
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)

                    Button {
                        onSend(addressText, pinCoordinate)
                        dismiss()
                    } label: {
                        Text("Envoyer cette adresse")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(ArtisgoTheme.orange)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(addressText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Envoyer mon adresse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(ArtisgoTheme.orange)
                }
            }
            .safeAreaInset(edge: .top) {
                Text("Tapez sur la carte pour placer le point précis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
            }
            .task {
                await centerOnUserLocation()
            }
        }
    }

    // Centrer la carte sur la position utilisateur au démarrage
    private func centerOnUserLocation() async {
        if let loc = try? await locationService.requestCurrentLocation() {
            pinCoordinate = loc.coordinate
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
            await reverseGeocode(loc.coordinate)
        }
    }

    // Conversion coordonnée -> adresse lisible
    private func reverseGeocode(_ coord: CLLocationCoordinate2D) async {
        isGeocoding = true
        defer { isGeocoding = false }
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        if let place = try? await locationService.reverseGeocode(location), !place.adresseComplete.isEmpty {
            addressText = place.adresseComplete
        }
    }
}

// MARK: - Composant d'affichage d'une adresse reçue dans le chat
struct AdresseMessageView: View {
    let address: String
    let isFromClient: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                Text("Adresse du chantier")
                    .font(.caption.bold())
            }
            .foregroundStyle(isFromClient ? .white.opacity(0.9) : .secondary)

            HStack(spacing: 12) {
                // Mini carte statique
                Color(.secondarySystemBackground)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "map.fill")
                            .font(.title2)
                            .foregroundStyle(ArtisgoTheme.orange)
                    }
                    .clipShape(.rect(cornerRadius: 8))

                Text(address)
                    .font(.caption)
                    .foregroundStyle(isFromClient ? .white : .primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                Spacer(minLength: 0)
            }

            Button {
                openInMaps()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    Text("Ouvrir dans Plans")
                }
                .font(.caption.bold())
                .foregroundStyle(isFromClient ? ArtisgoTheme.orange : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isFromClient ? Color.white : ArtisgoTheme.orange)
                .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(12)
        .frame(maxWidth: 260, alignment: .leading)
        .background(isFromClient ? ArtisgoTheme.orange : Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func openInMaps() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, _ in
            if let p = placemarks?.first, let loc = p.location {
                let item = MKMapItem(placemark: MKPlacemark(coordinate: loc.coordinate))
                item.name = "Chantier"
                item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } else {
                let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
