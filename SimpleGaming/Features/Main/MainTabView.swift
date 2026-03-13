import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ReelsView()
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
