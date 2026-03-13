import Kingfisher
import SwiftUI

struct FullScreenImageViewer: View {
    let images: [String]
    let onDismiss: () -> Void

    @State private var currentIndex: Int

    private var topSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 44
    }

    init(images: [String], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.images = images
        self.onDismiss = onDismiss
        _currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    KFImage(URL(string: images[index]))
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5), in: Circle())
            }
            .padding(.top, topSafeArea + 8)
            .padding(.trailing, 20)
        }
    }
}
