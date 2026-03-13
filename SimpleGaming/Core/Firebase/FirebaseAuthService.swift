@preconcurrency import FirebaseAuth

final class FirebaseAuthService: AuthService {
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func makeAuthStateStream() -> AsyncStream<AuthState> {
        let (stream, continuation) = AsyncStream.makeStream(of: AuthState.self)
        let handle = Auth.auth().addStateDidChangeListener { _, user in
            let state: AuthState = user.map { .loggedIn(userId: $0.uid) } ?? .loggedOut
            continuation.yield(state)
        }
        continuation.onTermination = { _ in
            Auth.auth().removeStateDidChangeListener(handle)
        }
        return stream
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw AppError.authFailed(error.localizedDescription)
        }
    }
}
