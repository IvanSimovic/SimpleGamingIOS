// Phase 3: implement with ReelsFirestoreSource.
struct ReelsRepositoryImpl: ReelsRepository {
    func fetchReelGameIds() -> AsyncStream<[Int]> {
        AsyncStream { continuation in continuation.finish() }
    }
}
