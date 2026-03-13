struct ReelGame: Sendable, Equatable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let heroImageUrl: String?
    let metacriticScore: Int?
    let rating: Double?
    let genres: [String]
    let platforms: [String]
    let playtime: Int?
    let screenshotUrls: [String]
}
