struct FetchReelIdsUseCase: Sendable {
    let fetch: @Sendable () -> AsyncThrowingStream<[Int], Error>

    func callAsFunction() async throws -> [Int] {
        for try await ids in fetch() {
            return ids
        }
        return []
    }
}
