import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var viewModel
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
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
        .tint(Color(red: 1.0, green: 0.384, blue: 0.0))
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
