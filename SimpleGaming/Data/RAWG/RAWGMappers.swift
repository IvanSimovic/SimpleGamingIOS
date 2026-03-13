enum RAWGMappers {
    static func toGames(_ response: RAWGGameListResponse) -> [Game] {
        (response.results ?? []).compactMap { summary in
            guard let id = summary.id, let name = summary.name else { return nil }
            return Game(id: id, name: name, imageUrl: summary.backgroundImage)
        }
    }

    static func toReelGame(_ response: RAWGGameDetailResponse) -> ReelGame? {
        guard let id = response.id, let name = response.name else { return nil }
        return ReelGame(
            id: id,
            name: name,
            description: response.descriptionRaw,
            heroImageUrl: response.backgroundImage,
            metacriticScore: response.metacritic,
            rating: response.rating,
            genres: response.genres?.compactMap(\.name) ?? [],
            platforms: response.platforms?.compactMap { $0.platform?.name } ?? [],
            playtime: response.playtime,
            screenshotUrls: []
        )
    }

    static func toScreenshotUrls(_ response: RAWGScreenshotsResponse) -> [String] {
        (response.results ?? []).compactMap(\.image)
    }
}
