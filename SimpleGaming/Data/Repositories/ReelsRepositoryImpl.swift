struct ReelsRepositoryImpl: ReelsRepository {
    private let source: ReelsFirestoreSource

    init(source: ReelsFirestoreSource = ReelsFirestoreSource()) {
        self.source = source
    }

    func fetchReelGameIds() -> AsyncStream<[Int]> {
        source.fetchReelGameIds()
    }
}
