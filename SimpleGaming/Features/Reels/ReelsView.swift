import SwiftUI

// Phase 4: implement with ReelsViewModel and vertical paging TabView.
// Each page is a ReelCardView. Prefetch triggered via viewModel.didPageTo(index:).
struct ReelsView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Reels")
                .font(AppFont.head3)
                .foregroundStyle(Color.textMuted)
        }
    }
}
