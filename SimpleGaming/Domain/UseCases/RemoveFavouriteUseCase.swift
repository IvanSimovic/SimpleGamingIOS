struct RemoveFavouriteUseCase: Sendable {
    let remove: @Sendable (Int, String) async throws -> Void

    func callAsFunction(gameId: Int, userId: String) async throws {
        try await remove(gameId, userId)
    }
}
