struct SearchGamesUseCase: Sendable {
    let search: @Sendable (String) async throws -> [Game]

    func callAsFunction(_ query: String) async throws -> [Game] {
        try await search(query)
    }
}
