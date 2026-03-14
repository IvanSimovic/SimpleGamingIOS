import SwiftUI

struct MainTabView: View {
    @Environment(\.appEnvironment) private var env

    var body: some View {
        TabView {
            ReelsView(
                fetchReelIds: env.fetchReelIds,
                fetchReelGame: env.fetchReelGame,
                fetchFavourites: env.fetchFavourites,
                addFavourite: env.addFavourite,
                removeFavourite: env.removeFavourite,
                authService: env.authService
            )
            .tabItem {
                Label("tab_reels", systemImage: "gamecontroller.fill")
            }

            FavouritesView(
                fetchFavourites: env.fetchFavourites,
                removeFavourite: env.removeFavourite,
                searchGames: env.searchGames,
                addFavourite: env.addFavourite,
                authService: env.authService
            )
            .tabItem {
                Label("tab_favourites", systemImage: "heart.fill")
            }
        }
        .tint(Color.brandPrimary)
    }
}
