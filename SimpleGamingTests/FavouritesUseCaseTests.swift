import Foundation
import Testing
@testable import SimpleGaming

private final class Capture<T>: @unchecked Sendable {
    var value: T?
}

@Suite("AddFavouriteUseCase")
struct AddFavouriteUseCaseTests {
    @Test func forwardsGameAndUserId() async throws {
        let capturedId = Capture<Int>()
        let capturedName = Capture<String>()
        let capturedImageUrl = Capture<String>()
        let capturedUserId = Capture<String>()

        let useCase = AddFavouriteUseCase(add: { game, userId in
            capturedId.value = game.id
            capturedName.value = game.name
            capturedImageUrl.value = game.imageUrl
            capturedUserId.value = userId
        })

        let game = Game(id: 3498, name: "Grand Theft Auto V", imageUrl: "https://example.com/gta.jpg")
        try await useCase(game: game, userId: "user-123")

        #expect(capturedId.value == 3498)
        #expect(capturedName.value == "Grand Theft Auto V")
        #expect(capturedImageUrl.value == "https://example.com/gta.jpg")
        #expect(capturedUserId.value == "user-123")
    }

    @Test func forwardsNilImageUrl() async throws {
        let capturedId = Capture<Int>()
        let imageUrlWasNil = Capture<Bool>()

        let useCase = AddFavouriteUseCase(add: { game, _ in
            capturedId.value = game.id
            imageUrlWasNil.value = game.imageUrl == nil
        })

        try await useCase(game: Game(id: 42, name: "No Image Game", imageUrl: nil), userId: "user-123")

        #expect(capturedId.value == 42)
        #expect(imageUrlWasNil.value == true)
    }

    @Test func propagatesError() async {
        let useCase = AddFavouriteUseCase(add: { _, _ in
            throw AppError.firestoreError("write failed")
        })

        await #expect(throws: AppError.firestoreError("write failed")) {
            try await useCase(game: Game(id: 1, name: "Test", imageUrl: nil), userId: "user-123")
        }
    }
}

@Suite("RemoveFavouriteUseCase")
struct RemoveFavouriteUseCaseTests {
    @Test func forwardsGameIdAndUserId() async throws {
        let capturedGameId = Capture<Int>()
        let capturedUserId = Capture<String>()

        let useCase = RemoveFavouriteUseCase(remove: { gameId, userId in
            capturedGameId.value = gameId
            capturedUserId.value = userId
        })

        try await useCase(gameId: 3498, userId: "user-123")

        #expect(capturedGameId.value == 3498)
        #expect(capturedUserId.value == "user-123")
    }

    @Test func propagatesError() async {
        let useCase = RemoveFavouriteUseCase(remove: { _, _ in
            throw AppError.firestoreError("delete failed")
        })

        await #expect(throws: AppError.firestoreError("delete failed")) {
            try await useCase(gameId: 1, userId: "user-123")
        }
    }
}

@Suite("FetchFavouritesUseCase")
struct FetchFavouritesUseCaseTests {
    @Test func emitsValuesFromStream() async {
        let expected = [
            FavouriteGame(id: 3498, name: "Grand Theft Auto V", imageUrl: "https://example.com/gta.jpg", addedAt: .now),
            FavouriteGame(id: 4200, name: "Portal 2", imageUrl: nil, addedAt: .now),
        ]

        let useCase = FetchFavouritesUseCase(fetch: { _ in
            AsyncStream { continuation in
                continuation.yield(expected)
                continuation.finish()
            }
        })

        var received: [[FavouriteGame]] = []
        for await games in useCase(userId: "user-123") {
            received.append(games)
        }

        #expect(received.count == 1)
        #expect(received[0].map(\.id) == [3498, 4200])
        #expect(received[0].map(\.name) == ["Grand Theft Auto V", "Portal 2"])
    }

    @Test func emitsMultipleUpdates() async {
        let batch1 = [FavouriteGame(id: 1, name: "Game A", imageUrl: nil, addedAt: .now)]
        let batch2 = [
            FavouriteGame(id: 1, name: "Game A", imageUrl: nil, addedAt: .now),
            FavouriteGame(id: 2, name: "Game B", imageUrl: nil, addedAt: .now),
        ]

        let useCase = FetchFavouritesUseCase(fetch: { _ in
            AsyncStream { continuation in
                continuation.yield(batch1)
                continuation.yield(batch2)
                continuation.finish()
            }
        })

        var received: [[FavouriteGame]] = []
        for await games in useCase(userId: "user-123") {
            received.append(games)
        }

        #expect(received.count == 2)
        #expect(received[0].count == 1)
        #expect(received[1].count == 2)
    }

    @Test func passesUserIdToFetch() async {
        let capturedUserId = Capture<String>()

        let useCase = FetchFavouritesUseCase(fetch: { userId in
            capturedUserId.value = userId
            return AsyncStream { continuation in continuation.finish() }
        })

        for await _ in useCase(userId: "user-abc") {}

        #expect(capturedUserId.value == "user-abc")
    }

    @Test func emitsEmptyListWhenNoFavourites() async {
        let useCase = FetchFavouritesUseCase(fetch: { _ in
            AsyncStream { continuation in
                continuation.yield([])
                continuation.finish()
            }
        })

        var received: [[FavouriteGame]] = []
        for await games in useCase(userId: "user-123") {
            received.append(games)
        }

        #expect(received.count == 1)
        #expect(received[0].isEmpty)
    }
}
