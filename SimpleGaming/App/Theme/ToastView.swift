import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(AppFont.body2)
            .foregroundStyle(.white)
            .padding(.horizontal, AppDimen.spaceXL)
            .padding(.vertical, AppDimen.spaceM)
            .background(Color.black.opacity(0.85), in: Capsule())
    }
}

extension View {
    func toast(message: String?) -> some View {
        overlay(alignment: .bottom) {
            if let message {
                ToastView(message: message)
                    .padding(.horizontal, AppDimen.screenPadding)
                    .padding(.bottom, AppDimen.spaceXL)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: message)
    }
}
