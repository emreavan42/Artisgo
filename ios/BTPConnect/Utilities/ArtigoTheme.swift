import SwiftUI

enum ArtigoTheme {
    static let orange = Color(hex: "FF6200")
    static let lightBlue = Color(hex: "E8F4FD")
    static let darkBlue = Color(hex: "1B3A5C")
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let cornerRadius: CGFloat = 14
}

struct ArtigoLogoView: View {
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Color(hex: "1A1A2E"))
                .frame(width: size, height: size)

            VStack(spacing: -size * 0.04) {
                Image(systemName: "house.fill")
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundStyle(.white)

                RoundedRectangle(cornerRadius: 1)
                    .fill(ArtigoTheme.orange)
                    .frame(width: size * 0.28, height: size * 0.22)
                    .offset(y: -size * 0.06)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
