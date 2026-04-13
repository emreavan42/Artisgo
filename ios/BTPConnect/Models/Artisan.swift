import Foundation
import CoreLocation

nonisolated struct Artisan: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let profession: String
    let rating: Double
    let distance: Double
    let pricePerSqm: Int
    let description: String
    let isAvailable: Bool
    let isUrgent: Bool
    let avatarURL: String?
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: Artisan, rhs: Artisan) -> Bool {
        lhs.id == rhs.id
    }
}
