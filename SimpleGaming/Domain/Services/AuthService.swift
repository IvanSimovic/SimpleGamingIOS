protocol AuthService: Sendable {
    var currentUserId: String? { get }
    func makeAuthStateStream() -> AsyncStream<AuthState>
    func signIn(email: String, password: String) async throws
}
