import Foundation

enum ReelsState: Sendable, Equatable {
    case loading
    case empty
    case ready(cards: [ReelCardState], favouriteIds: Set<Int>)
    case failed(AppError)
}

@Observable
@MainActor
final class ReelsViewModel {
    private(set) var state: ReelsState = .loading

    private let fetchReelIds: FetchReelIdsUseCase
    private let fetchReelGame: FetchReelGameUseCase
    private let fetchFavourites: FetchFavouritesUseCase
    private let addFavourite: AddFavouriteUseCase
    private let removeFavourite: RemoveFavouriteUseCase
    private let authService: any AuthService

    private var fetchTasks: [Int: Task<Void, Never>] = [:]
    private var favouritesTask: Task<Void, Never>?
    private var toggleTask: Task<Void, Never>?
    private var currentFavouriteIds: Set<Int> = []

    init(
        fetchReelIds: FetchReelIdsUseCase,
        fetchReelGame: FetchReelGameUseCase,
        fetchFavourites: FetchFavouritesUseCase,
        addFavourite: AddFavouriteUseCase,
        removeFavourite: RemoveFavouriteUseCase,
        authService: any AuthService
    ) {
        self.fetchReelIds = fetchReelIds
        self.fetchReelGame = fetchReelGame
        self.fetchFavourites = fetchFavourites
        self.addFavourite = addFavourite
        self.removeFavourite = removeFavourite
        self.authService = authService
    }

    func load() async {
        fetchTasks.values.forEach { $0.cancel() }
        fetchTasks.removeAll()
        favouritesTask?.cancel()
        toggleTask?.cancel()
        currentFavouriteIds = []
        state = .loading

        if let userId = authService.currentUserId {
            favouritesTask = Task {
                for await games in fetchFavourites(userId: userId) {
                    updateFavouriteIds(Set(games.map(\.id)))
                }
            }
        }

        let ids = await fetchReelIds()
        guard !ids.isEmpty else {
            state = .empty
            return
        }
        state = .ready(cards: ids.map { .loading(id: $0) }, favouriteIds: currentFavouriteIds)
        prefetch(index: 0)
        prefetch(index: 1)
    }

    func didPageTo(index: Int) {
        prefetch(index: index + 1)
    }

    func toggleFavourite(game: ReelGame) {
        guard let userId = authService.currentUserId else { return }
        toggleTask?.cancel()
        toggleTask = Task {
            if currentFavouriteIds.contains(game.id) {
                try? await removeFavourite(gameId: game.id, userId: userId)
            } else {
                try? await addFavourite(
                    game: Game(id: game.id, name: game.name, imageUrl: game.heroImageUrl),
                    userId: userId
                )
            }
        }
    }

    private func updateFavouriteIds(_ ids: Set<Int>) {
        currentFavouriteIds = ids
        if case .ready(let cards, _) = state {
            state = .ready(cards: cards, favouriteIds: ids)
        }
    }

    private func prefetch(index: Int) {
        guard case .ready(let cards, _) = state else { return }
        guard index < cards.count else { return }
        guard case .loading = cards[index] else { return }
        guard fetchTasks[index] == nil else { return }

        let id = cards[index].id
        fetchTasks[index] = Task {
            do {
                let game = try await fetchReelGame(id: id)
                updateCard(at: index, with: .loaded(game))
            } catch is CancellationError {
            } catch let error as AppError {
                updateCard(at: index, with: .failed(id: id, error))
            } catch {
                updateCard(at: index, with: .failed(id: id, .unknown(error.localizedDescription)))
            }
            fetchTasks[index] = nil
        }
    }

    private func updateCard(at index: Int, with cardState: ReelCardState) {
        guard case .ready(var cards, let favouriteIds) = state, index < cards.count else { return }
        cards[index] = cardState
        state = .ready(cards: cards, favouriteIds: favouriteIds)
    }
}
