import SwiftUI

@MainActor
struct RootView: View {
    @Environment(\.appEnvironment) private var env
    @State private var authState: AuthState = .loggedOut

    var body: some View {
        Group {
            switch authState {
            case .loggedOut:
                AuthView(signIn: env.signIn)
            case .loggedIn:
                MainTabView()
            }
        }
        .task {
            for await state in env.authService.makeAuthStateStream() {
                authState = state
            }
        }
    }
}
