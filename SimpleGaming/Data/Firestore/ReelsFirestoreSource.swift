@preconcurrency import FirebaseFirestore

private enum Collection {
    static let gameStats = "gameStats"
}

private enum Field {
    static let saveCount = "saveCount"
}

struct ReelsFirestoreSource {
    private static let pageSize = 50

    func fetchReelGameIds() -> AsyncStream<[Int]> {
        AsyncStream { continuation in
            Task {
                do {
                    let snapshot = try await Firestore.firestore()
                        .collection(Collection.gameStats)
                        .order(by: Field.saveCount, descending: true)
                        .limit(to: Self.pageSize)
                        .getDocuments()

                    let ids = snapshot.documents.compactMap { Int($0.documentID) }
                    continuation.yield(ids)
                } catch {}
                continuation.finish()
            }
        }
    }
}
