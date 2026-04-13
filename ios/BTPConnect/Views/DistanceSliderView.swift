import SwiftUI

struct DistanceSliderView: View {
    @Binding var selectedRadius: Int

    private let steps = [20, 40, 60, 80, 100, 150, 200, 250]
    private let labels = ["20 km", "40 km", "60 km", "80 km", "100 km", "150…", "200…", "200+"]

    private var currentIndex: Int {
        steps.firstIndex(of: selectedRadius) ?? 1
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let stepWidth = totalWidth / CGFloat(steps.count - 1)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(height: 4)

                    Capsule()
                        .fill(ArtigoTheme.orange)
                        .frame(width: CGFloat(currentIndex) * stepWidth, height: 4)

                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i <= currentIndex ? ArtigoTheme.orange : Color(.systemGray4))
                            .frame(width: 8, height: 8)
                            .offset(x: CGFloat(i) * stepWidth - 4)
                    }

                    Circle()
                        .fill(ArtigoTheme.orange)
                        .frame(width: 24, height: 24)
                        .shadow(color: ArtigoTheme.orange.opacity(0.3), radius: 4, y: 2)
                        .offset(x: CGFloat(currentIndex) * stepWidth - 12)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x
                                    let index = Int(round(x / stepWidth))
                                    let clampedIndex = max(0, min(steps.count - 1, index))
                                    selectedRadius = steps[clampedIndex]
                                }
                        )
                }
                .frame(height: 24)
            }
            .frame(height: 24)

            HStack {
                ForEach(0..<labels.count, id: \.self) { i in
                    Text(labels[i])
                        .font(.system(size: 9))
                        .foregroundStyle(i == currentIndex ? ArtigoTheme.orange : .secondary)
                        .fontWeight(i == currentIndex ? .bold : .regular)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}
