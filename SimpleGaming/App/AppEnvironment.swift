import SwiftUI

struct AppEnvironment {
    let signIn: @Sendable (String, String) async throws -> Void
    let authService: any AuthService

    let gameRepository: any GameRepository
    let favouritesRepository: any FavouritesRepository
    let reelsRepository: any ReelsRepository

    let searchGames: SearchGamesUseCase
    let addFavourite: AddFavouriteUseCase
    let removeFavourite: RemoveFavouriteUseCase
    let fetchFavourites: FetchFavouritesUseCase
    let fetchReels: FetchReelsUseCase
}

extension AppEnvironment {
    static func live() -> AppEnvironment {
        let authService = FirebaseAuthService()
        let gameRepository = GameRepositoryImpl()
        let favouritesRepository = FavouritesRepositoryImpl()
        let reelsRepository = ReelsRepositoryImpl()
        let rawgClient = RAWGClient()

        return AppEnvironment(
            signIn: { email, password in
                try await authService.signIn(email: email, password: password)
            },
            authService: authService,
            gameRepository: gameRepository,
            favouritesRepository: favouritesRepository,
            reelsRepository: reelsRepository,
            searchGames: SearchGamesUseCase(search: { query in
                try await rawgClient.searchGames(query: query)
            }),
            addFavourite: AddFavouriteUseCase(add: { game, userId in
                try await favouritesRepository.add(game: game, userId: userId)
            }),
            removeFavourite: RemoveFavouriteUseCase(remove: { gameId, userId in
                try await favouritesRepository.remove(gameId: gameId, userId: userId)
            }),
            fetchFavourites: FetchFavouritesUseCase(fetch: { userId in
                favouritesRepository.observeFavourites(userId: userId)
            }),
            fetchReels: FetchReelsUseCase(fetch: { _, _ in AsyncStream { _ in } })
        )
    }

    static func stub() -> AppEnvironment {
        AppEnvironment(
            signIn: { _, _ in },
            authService: StubAuthService(),
            gameRepository: StubGameRepository(),
            favouritesRepository: StubFavouritesRepository(),
            reelsRepository: StubReelsRepository(),
            searchGames: SearchGamesUseCase(search: { _ in [] }),
            addFavourite: AddFavouriteUseCase(add: { _, _ in }),
            removeFavourite: RemoveFavouriteUseCase(remove: { _, _ in }),
            fetchFavourites: FetchFavouritesUseCase(fetch: { _ in AsyncStream { _ in } }),
            fetchReels: FetchReelsUseCase(fetch: { _, _ in AsyncStream { _ in } })
        )
    }
}

private struct StubAuthService: AuthService {
    var currentUserId: String? { nil }
    func makeAuthStateStream() -> AsyncStream<AuthState> { AsyncStream { _ in } }
    func signIn(email: String, password: String) async throws {}
}

private struct StubGameRepository: GameRepository {
    func fetchGame(id: Int) async throws -> ReelGame { throw AppError.notFound }
    func fetchScreenshots(gameId: Int) async throws -> [String] { [] }
}

private struct StubFavouritesRepository: FavouritesRepository {
    func observeFavourites(userId: String) -> AsyncStream<[FavouriteGame]> { AsyncStream { _ in } }
    func add(game: Game, userId: String) async throws {}
    func remove(gameId: Int, userId: String) async throws {}
}

private struct StubReelsRepository: ReelsRepository {
    func fetchReelGameIds() -> AsyncStream<[Int]> { AsyncStream { _ in } }
}

private struct AppEnvironmentKey: EnvironmentKey {
    nonisolated static var defaultValue: AppEnvironment { .stub() }
}

extension EnvironmentValues {
    nonisolated var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
