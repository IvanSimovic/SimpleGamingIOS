import Foundation

enum AuthUiState: Sendable, Equatable {
    case idle
    case loading
    case failed(String)
}

@Observable
@MainActor
final class AuthViewModel {
    private(set) var state: AuthUiState = .idle
    var email = "test@gmail.com"
    var password = "test21"

    private let signIn: @Sendable (String, String) async throws -> Void

    init(signIn: @escaping @Sendable (String, String) async throws -> Void) {
        self.signIn = signIn
    }

    func signInTapped() async {
        state = .loading
        do {
            try await signIn(email, password)
            // RootView observes auth state from FirebaseAuthService — no state update needed here.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
