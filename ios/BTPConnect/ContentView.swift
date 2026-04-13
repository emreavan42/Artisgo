import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        TabView(selection: $viewModel.selectedTab) {
            Tab("Accueil", systemImage: "house.fill", value: .home) {
                HomeView()
            }
            Tab("Recherche", systemImage: "magnifyingglass", value: .search) {
                SearchView()
            }
            Tab("Messages", systemImage: "message.fill", value: .messages) {
                MessagesListView()
            }
            .badge(viewModel.totalUnread)
            Tab("Favoris", systemImage: "heart.fill", value: .favorites) {
                FavoritesView()
            }
            Tab("Profil", systemImage: "person.fill", value: .profile) {
                ProfileView()
            }
        }
    }
}
