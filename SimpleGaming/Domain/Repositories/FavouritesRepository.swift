protocol FavouritesRepository: Sendable {
    func observeFavourites(userId: String) -> AsyncStream<[FavouriteGame]>
    func add(game: FavouriteGame, userId: String) async throws
    func remove(gameId: Int, userId: String) async throws
}
