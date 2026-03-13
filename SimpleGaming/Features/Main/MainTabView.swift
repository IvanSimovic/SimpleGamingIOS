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
                Label("Reels", systemImage: "gamecontroller.fill")
            }

            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "heart.fill")
                }
        }
        .tint(Color.brandPrimary)
    }
}
