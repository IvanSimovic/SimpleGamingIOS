import SwiftUI

struct ShimmerView: View {
    let phase: CGFloat

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            Color.appDivider
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.appSurface.opacity(0.8), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 0.6)
                    .offset(x: phase * width)
                )
                .clipped()
        }
    }
}
