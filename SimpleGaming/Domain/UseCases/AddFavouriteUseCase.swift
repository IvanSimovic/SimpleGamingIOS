struct AddFavouriteUseCase: Sendable {
    let add: @Sendable (Game, String) async throws -> Void

    func callAsFunction(game: Game, userId: String) async throws {
        try await add(game, userId)
    }
}
