@preconcurrency import FirebaseFirestore
import Foundation

private enum Collection {
    static let users = "users"
    static let favouriteGames = "favouriteGames"
}

private enum Field {
    static let gameId = "gameId"
    static let name = "name"
    static let imageUrl = "imageUrl"
    static let addedAt = "addedAt"
    static let saveCount = "saveCount"
}

struct FavouritesFirestoreSource {
    func observeFavourites(userId: String) -> AsyncStream<[FavouriteGame]> {
        let (stream, continuation) = AsyncStream.makeStream(of: [FavouriteGame].self)
        let db = Firestore.firestore()

        let listener = db
            .collection(Collection.users)
            .document(userId)
            .collection(Collection.favouriteGames)
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    continuation.finish()
                    return
                }
                let games = snapshot?.documents.compactMap(Self.parseDocument) ?? []
                continuation.yield(games)
            }

        continuation.onTermination = { _ in listener.remove() }
        return stream
    }

    func add(game: Game, userId: String) async throws {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            Field.gameId: String(game.id),
            Field.name: game.name,
            Field.imageUrl: game.imageUrl ?? "",
            Field.addedAt: FieldValue.serverTimestamp(),
        ]
        try await db
            .collection(Collection.users)
            .document(userId)
            .collection(Collection.favouriteGames)
            .document(String(game.id))
            .setData(data)
    }

    func remove(gameId: Int, userId: String) async throws {
        let db = Firestore.firestore()
        try await db
            .collection(Collection.users)
            .document(userId)
            .collection(Collection.favouriteGames)
            .document(String(gameId))
            .delete()
    }

    private static func parseDocument(_ doc: QueryDocumentSnapshot) -> FavouriteGame? {
        let data = doc.data()
        guard
            let gameIdString = data[Field.gameId] as? String,
            let gameId = Int(gameIdString),
            let name = data[Field.name] as? String
        else { return nil }

        let rawImageUrl = data[Field.imageUrl] as? String
        let imageUrl = rawImageUrl?.isEmpty == false ? rawImageUrl : nil
        let addedAt = (data[Field.addedAt] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)

        return FavouriteGame(id: gameId, name: name, imageUrl: imageUrl, addedAt: addedAt)
    }
}
