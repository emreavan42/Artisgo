import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        @Bindable var viewModel = viewModel
        TabView(selection: $viewModel.selectedTab) {
            Tab("Accueil", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Recherche", systemImage: "magnifyingglass", value: AppTab.search) {
                SearchView()
            }
            Tab("Messages", systemImage: "message.fill", value: AppTab.messages) {
                MessagesListView()
            }
            .badge(viewModel.totalUnread)
            Tab("Profil", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
