import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var showPostChantier: Bool = false

    var body: some View {
        @Bindable var viewModel = viewModel
        TabView(selection: $viewModel.selectedTab) {
            Tab("Accueil", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Recherche", systemImage: "magnifyingglass", value: AppTab.search) {
                SearchView()
            }
            Tab("Poster", systemImage: "plus.circle.fill", value: AppTab.postChantier) {
                Color.clear
            }
            Tab("Messages", systemImage: "message.fill", value: AppTab.messages) {
                MessagesListView()
            }
            .badge(viewModel.totalUnread)
            Tab("Profil", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(ArtisgoTheme.orange)
        .onChange(of: viewModel.selectedTab) { oldValue, newValue in
            if newValue == .postChantier {
                viewModel.selectedTab = oldValue
                showPostChantier = true
            }
        }
        .sheet(isPresented: $showPostChantier) {
            NavigationStack {
                PostChantierView()
            }
        }
    }
}
