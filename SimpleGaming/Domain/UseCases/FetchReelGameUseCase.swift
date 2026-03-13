struct FetchReelGameUseCase: Sendable {
    let fetchGame: @Sendable (Int) async throws -> ReelGame
    let fetchScreenshots: @Sendable (Int) async throws -> [String]

    func callAsFunction(id: Int) async throws -> ReelGame {
        async let game = fetchGame(id)
        async let screenshots = fetchScreenshots(id)
        let result = try await game
        let urls = (try? await screenshots) ?? []
        return ReelGame(
            id: result.id,
            name: result.name,
            description: result.description,
            heroImageUrl: result.heroImageUrl,
            metacriticScore: result.metacriticScore,
            rating: result.rating,
            genres: result.genres,
            platforms: result.platforms,
            playtime: result.playtime,
            screenshotUrls: urls
        )
    }
}
