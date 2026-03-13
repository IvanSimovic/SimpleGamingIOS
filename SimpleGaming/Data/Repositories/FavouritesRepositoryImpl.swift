// Phase 3: implement with FavouritesFirestoreSource.
struct FavouritesRepositoryImpl: FavouritesRepository {
    func observeFavourites(userId: String) -> AsyncStream<[FavouriteGame]> {
        AsyncStream { continuation in continuation.finish() }
    }

    func add(game: FavouriteGame, userId: String) async throws {
        preconditionFailure("FavouritesRepositoryImpl.add not implemented until Phase 3")
    }

    func remove(gameId: Int, userId: String) async throws {
        preconditionFailure("FavouritesRepositoryImpl.remove not implemented until Phase 3")
    }
}
