import Foundation
import CoreLocation
import Combine

// MARK: - Service de localisation (CoreLocation + géocodage)
@Observable
@MainActor
final class LocationService: NSObject {
    // Statut d'autorisation actuel
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    // Dernière position connue
    var lastLocation: CLLocation?
    // Erreur éventuelle
    var errorMessage: String?

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    // Demande la permission et récupère la position une fois
    func requestCurrentLocation() async throws -> CLLocation {
        errorMessage = nil
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            throw LocationError.denied
        default:
            break
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }

    // Conversion coordonnées -> ville / code postal
    func reverseGeocode(_ location: CLLocation) async throws -> GeocodedPlace {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let p = placemarks.first else {
            throw LocationError.geocodingFailed
        }
        return GeocodedPlace(
            ville: p.locality ?? p.subAdministrativeArea ?? "",
            codePostal: p.postalCode ?? "",
            adresseComplete: formatAddress(p),
            coordinate: location.coordinate
        )
    }

    // Recherche de villes par autocomplete
    func searchCities(_ query: String) async throws -> [GeocodedPlace] {
        guard query.count >= 2 else { return [] }
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(query, in: nil, preferredLocale: Locale(identifier: "fr_FR"))
        return placemarks.compactMap { p -> GeocodedPlace? in
            guard let coord = p.location?.coordinate,
                  let ville = p.locality ?? p.subAdministrativeArea else { return nil }
            return GeocodedPlace(
                ville: ville,
                codePostal: p.postalCode ?? "",
                adresseComplete: formatAddress(p),
                coordinate: coord
            )
        }
    }

    nonisolated private func formatAddress(_ p: CLPlacemark) -> String {
        var parts: [String] = []
        if let n = p.subThoroughfare, let s = p.thoroughfare {
            parts.append("\(n) \(s)")
        } else if let s = p.thoroughfare {
            parts.append(s)
        }
        var cpVille: [String] = []
        if let cp = p.postalCode { cpVille.append(cp) }
        if let ville = p.locality { cpVille.append(ville) }
        if !cpVille.isEmpty { parts.append(cpVille.joined(separator: " ")) }
        return parts.joined(separator: ", ")
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .denied || status == .restricted {
                self.locationContinuation?.resume(throwing: LocationError.denied)
                self.locationContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.lastLocation = loc
            self.locationContinuation?.resume(returning: loc)
            self.locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.locationContinuation?.resume(throwing: error)
            self.locationContinuation = nil
        }
    }
}

// MARK: - Modèles
nonisolated struct GeocodedPlace: Identifiable, Hashable, Sendable {
    var id: String { "\(ville)-\(codePostal)-\(coordinate.latitude)-\(coordinate.longitude)" }
    let ville: String
    let codePostal: String
    let adresseComplete: String
    let coordinate: CLLocationCoordinate2D

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: GeocodedPlace, rhs: GeocodedPlace) -> Bool { lhs.id == rhs.id }
}

nonisolated enum LocationError: LocalizedError, Sendable {
    case denied
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .denied: return "Autorisez la localisation dans Réglages"
        case .geocodingFailed: return "Impossible de trouver l'adresse"
        }
    }
}
