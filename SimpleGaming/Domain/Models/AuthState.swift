enum AuthState: Sendable, Equatable {
    case loggedIn(userId: String)
    case loggedOut
}
