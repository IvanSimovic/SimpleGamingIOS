import SwiftUI

// Phase 5: implement with AddGameViewModel — debounced search (500ms, min 2 chars),
// results list, tap-to-add with confirmation feedback.
struct AddGameView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Text("Add Game")
                .font(AppFont.head3)
                .foregroundStyle(Color.textMuted)
        }
    }
}
