struct GameRepositoryImpl: GameRepository {
    private let client: RAWGClient

    init(client: RAWGClient = RAWGClient()) {
        self.client = client
    }

    func fetchGame(id: Int) async throws -> ReelGame {
        try await client.fetchGame(id: id)
    }

    func fetchScreenshots(gameId: Int) async throws -> [String] {
        try await client.fetchScreenshots(gameId: gameId)
    }
}
