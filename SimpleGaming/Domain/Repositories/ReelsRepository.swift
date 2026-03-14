// Reel game IDs are globally seeded by an admin — not scoped to a userId.
protocol ReelsRepository: Sendable {
    func fetchReelGameIds() -> AsyncThrowingStream<[Int], Error>
}
