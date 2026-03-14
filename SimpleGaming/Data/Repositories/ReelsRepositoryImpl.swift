struct ReelsRepositoryImpl: ReelsRepository {
    private let source: ReelsFirestoreSource

    init(source: ReelsFirestoreSource = ReelsFirestoreSource()) {
        self.source = source
    }

    func fetchReelGameIds() -> AsyncThrowingStream<[Int], Error> {
        source.fetchReelGameIds()
    }
}
