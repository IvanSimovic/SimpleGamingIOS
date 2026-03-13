struct FetchReelsUseCase: Sendable {
    let fetch: @Sendable ([Int], Int) -> AsyncStream<[ReelCardState]>

    func callAsFunction(gameIds: [Int], currentIndex: Int) -> AsyncStream<[ReelCardState]> {
        fetch(gameIds, currentIndex)
    }
}
