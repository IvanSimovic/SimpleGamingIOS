struct RAWGGameListResponse: Codable {
    let results: [RAWGGameSummary]?
}

struct RAWGGameSummary: Codable {
    let id: Int?
    let name: String?
    let backgroundImage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case backgroundImage = "background_image"
    }
}

struct RAWGGameDetailResponse: Codable {
    let id: Int?
    let name: String?
    let descriptionRaw: String?
    let backgroundImage: String?
    let metacritic: Int?
    let rating: Double?
    let genres: [RAWGGenre]?
    let platforms: [RAWGPlatformWrapper]?
    let playtime: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case descriptionRaw = "description_raw"
        case backgroundImage = "background_image"
        case metacritic
        case rating
        case genres
        case platforms
        case playtime
    }
}

struct RAWGGenre: Codable {
    let name: String?
}

struct RAWGPlatformWrapper: Codable {
    let platform: RAWGPlatform?
}

struct RAWGPlatform: Codable {
    let name: String?
}

struct RAWGScreenshotsResponse: Codable {
    let results: [RAWGScreenshot]?
}

struct RAWGScreenshot: Codable {
    let id: Int?
    let image: String?
}
