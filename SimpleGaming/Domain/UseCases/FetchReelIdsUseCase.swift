struct FetchReelIdsUseCase: Sendable {
    let fetch: @Sendable () -> AsyncStream<[Int]>

    func callAsFunction() async -> [Int] {
        for await ids in fetch() {
            return ids
        }
        return []
    }
}
