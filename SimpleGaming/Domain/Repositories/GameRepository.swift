protocol GameRepository: Sendable {
    func fetchGame(id: Int) async throws -> ReelGame
    func fetchScreenshots(gameId: Int) async throws -> [String]
}
