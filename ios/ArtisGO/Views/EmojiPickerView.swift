import SwiftUI

struct EmojiPickerView: View {
    let onSelect: (String) -> Void

    private let emojis = [
        "😀","😂","😍","🥰","😎","🤔","👍","👏","🙏","💪",
        "🔥","✅","❤️","⭐","🎉","💯","🛠️","🏗️","🏠","📋",
        "📞","💬","📸","📄","🗓️","⏰","💰","🔧","⚡","🌟"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emojis")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        onSelect(emoji)
                    } label: {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}
