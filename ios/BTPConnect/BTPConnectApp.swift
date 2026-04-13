import SwiftUI

@main
struct ArtigoApp: App {
    @State private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appViewModel)
                .tint(Color(hex: "FF6200"))
        }
    }
}
