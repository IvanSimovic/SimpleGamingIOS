import SwiftUI

// Phase 5: implement with FavouritesViewModel — live Firestore stream, delete support.
// FAB navigates to AddGameView as a sheet.
struct FavouritesView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Favourites")
                .font(AppFont.head3)
                .foregroundStyle(Color.textMuted)
        }
    }
}
