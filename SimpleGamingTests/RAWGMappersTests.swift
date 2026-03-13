import Foundation
import Testing
@testable import SimpleGaming

// MARK: - Helpers

private func decode<T: Decodable>(_ json: String, as type: T.Type = T.self) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
}

// MARK: - Game List

@Suite("RAWGMappers — game list")
struct GameListMappingTests {
    @Test func mapsFullResponseToGames() throws {
        let json = """
        {
          "results": [
            { "id": 3498, "name": "Grand Theft Auto V", "background_image": "https://example.com/gta.jpg" },
            { "id": 4200, "name": "Portal 2", "background_image": "https://example.com/portal.jpg" }
          ]
        }
        """
        let response = try decode(json, as: RAWGGameListResponse.self)
        let games = RAWGMappers.toGames(response)

        #expect(games.count == 2)
        #expect(games[0] == Game(id: 3498, name: "Grand Theft Auto V", imageUrl: "https://example.com/gta.jpg"))
        #expect(games[1] == Game(id: 4200, name: "Portal 2", imageUrl: "https://example.com/portal.jpg"))
    }

    @Test func mapsNullBackgroundImageToNilImageUrl() throws {
        let json = """
        {
          "results": [
            { "id": 1, "name": "No Image Game", "background_image": null }
          ]
        }
        """
        let response = try decode(json, as: RAWGGameListResponse.self)
        let games = RAWGMappers.toGames(response)

        #expect(games.count == 1)
        #expect(games[0].imageUrl == nil)
    }

    @Test func dropsEntriesWithMissingId() throws {
        let json = """
        {
          "results": [
            { "name": "No ID Game", "background_image": null },
            { "id": 5, "name": "Valid Game", "background_image": null }
          ]
        }
        """
        let response = try decode(json, as: RAWGGameListResponse.self)
        let games = RAWGMappers.toGames(response)

        #expect(games.count == 1)
        #expect(games[0].id == 5)
    }

    @Test func dropsEntriesWithMissingName() throws {
        let json = """
        {
          "results": [
            { "id": 1, "background_image": null },
            { "id": 2, "name": "Valid", "background_image": null }
          ]
        }
        """
        let response = try decode(json, as: RAWGGameListResponse.self)
        let games = RAWGMappers.toGames(response)

        #expect(games.count == 1)
        #expect(games[0].id == 2)
    }

    @Test func returnsEmptyArrayForNullResults() throws {
        let json = #"{ "results": null }"#
        let response = try decode(json, as: RAWGGameListResponse.self)
        #expect(RAWGMappers.toGames(response).isEmpty)
    }

    @Test func returnsEmptyArrayForEmptyResults() throws {
        let json = #"{ "results": [] }"#
        let response = try decode(json, as: RAWGGameListResponse.self)
        #expect(RAWGMappers.toGames(response).isEmpty)
    }
}

// MARK: - Game Detail

@Suite("RAWGMappers — game detail")
struct GameDetailMappingTests {
    @Test func mapsFullDetailResponseToReelGame() throws {
        let json = """
        {
          "id": 3498,
          "name": "Grand Theft Auto V",
          "description_raw": "An open world game.",
          "background_image": "https://example.com/hero.jpg",
          "metacritic": 97,
          "rating": 4.48,
          "genres": [{ "name": "Action" }, { "name": "Adventure" }],
          "platforms": [
            { "platform": { "name": "PC" } },
            { "platform": { "name": "PlayStation 4" } }
          ],
          "playtime": 72
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        let game = try #require(RAWGMappers.toReelGame(response))

        #expect(game.id == 3498)
        #expect(game.name == "Grand Theft Auto V")
        #expect(game.description == "An open world game.")
        #expect(game.heroImageUrl == "https://example.com/hero.jpg")
        #expect(game.metacriticScore == 97)
        #expect(game.rating == 4.48)
        #expect(game.genres == ["Action", "Adventure"])
        #expect(game.platforms == ["PC", "PlayStation 4"])
        #expect(game.playtime == 72)
        #expect(game.screenshotUrls.isEmpty)
    }

    @Test func returnsNilWhenIdIsMissing() throws {
        let json = """
        {
          "name": "No ID Game",
          "description_raw": null,
          "background_image": null,
          "metacritic": null,
          "rating": null,
          "genres": [],
          "platforms": [],
          "playtime": null
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        #expect(RAWGMappers.toReelGame(response) == nil)
    }

    @Test func returnsNilWhenNameIsMissing() throws {
        let json = """
        {
          "id": 1,
          "description_raw": null,
          "background_image": null,
          "metacritic": null,
          "rating": null,
          "genres": [],
          "platforms": [],
          "playtime": null
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        #expect(RAWGMappers.toReelGame(response) == nil)
    }

    @Test func mapsNullOptionalFieldsToNil() throws {
        let json = """
        {
          "id": 1,
          "name": "Minimal Game",
          "description_raw": null,
          "background_image": null,
          "metacritic": null,
          "rating": null,
          "genres": [],
          "platforms": [],
          "playtime": null
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        let game = try #require(RAWGMappers.toReelGame(response))

        #expect(game.description == nil)
        #expect(game.heroImageUrl == nil)
        #expect(game.metacriticScore == nil)
        #expect(game.rating == nil)
        #expect(game.playtime == nil)
    }

    @Test func mapsNullGenresAndPlatformsToEmptyArrays() throws {
        let json = """
        {
          "id": 1,
          "name": "Game",
          "description_raw": null,
          "background_image": null,
          "metacritic": null,
          "rating": null,
          "genres": null,
          "platforms": null,
          "playtime": null
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        let game = try #require(RAWGMappers.toReelGame(response))

        #expect(game.genres.isEmpty)
        #expect(game.platforms.isEmpty)
    }

    @Test func dropsPlatformsWithNullPlatformObject() throws {
        let json = """
        {
          "id": 1,
          "name": "Game",
          "description_raw": null,
          "background_image": null,
          "metacritic": null,
          "rating": null,
          "genres": [],
          "platforms": [
            { "platform": null },
            { "platform": { "name": "PC" } }
          ],
          "playtime": null
        }
        """
        let response = try decode(json, as: RAWGGameDetailResponse.self)
        let game = try #require(RAWGMappers.toReelGame(response))

        #expect(game.platforms == ["PC"])
    }
}

// MARK: - Screenshots

@Suite("RAWGMappers — screenshots")
struct ScreenshotsMappingTests {
    @Test func mapsScreenshotsResponseToUrls() throws {
        let json = """
        {
          "results": [
            { "id": 1, "image": "https://example.com/shot1.jpg" },
            { "id": 2, "image": "https://example.com/shot2.jpg" }
          ]
        }
        """
        let response = try decode(json, as: RAWGScreenshotsResponse.self)
        let urls = RAWGMappers.toScreenshotUrls(response)

        #expect(urls == ["https://example.com/shot1.jpg", "https://example.com/shot2.jpg"])
    }

    @Test func dropsScreenshotsWithNullImage() throws {
        let json = """
        {
          "results": [
            { "id": 1, "image": null },
            { "id": 2, "image": "https://example.com/valid.jpg" }
          ]
        }
        """
        let response = try decode(json, as: RAWGScreenshotsResponse.self)
        let urls = RAWGMappers.toScreenshotUrls(response)

        #expect(urls == ["https://example.com/valid.jpg"])
    }

    @Test func returnsEmptyForNullResults() throws {
        let json = #"{ "results": null }"#
        let response = try decode(json, as: RAWGScreenshotsResponse.self)
        #expect(RAWGMappers.toScreenshotUrls(response).isEmpty)
    }

    @Test func returnsEmptyForEmptyResults() throws {
        let json = #"{ "results": [] }"#
        let response = try decode(json, as: RAWGScreenshotsResponse.self)
        #expect(RAWGMappers.toScreenshotUrls(response).isEmpty)
    }
}
