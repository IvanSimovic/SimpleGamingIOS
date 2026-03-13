import Foundation

struct FavouritesRepositoryImpl: FavouritesRepository {
    private let source: FavouritesFirestoreSource

    init(source: FavouritesFirestoreSource = FavouritesFirestoreSource()) {
        self.source = source
    }

    func observeFavourites(userId: String) -> AsyncStream<[FavouriteGame]> {
        source.observeFavourites(userId: userId)
    }

    func add(game: Game, userId: String) async throws {
        do {
            try await source.add(game: game, userId: userId)
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }

    func remove(gameId: Int, userId: String) async throws {
        do {
            try await source.remove(gameId: gameId, userId: userId)
        } catch {
            throw AppError.firestoreError(error.localizedDescription)
        }
    }
}
