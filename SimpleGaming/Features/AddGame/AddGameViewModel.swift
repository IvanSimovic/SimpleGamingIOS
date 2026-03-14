import Foundation

enum SearchState: Sendable, Equatable {
    case idle
    case loading
    case loaded([Game])
    case failed(AppError)
}

struct AddGameState: Sendable, Equatable {
    var search: SearchState = .idle
    var addedGameIds: Set<Int> = []
    var addError: AppError? = nil
}

@Observable
@MainActor
final class AddGameViewModel {
    private(set) var state: AddGameState = AddGameState()

    private let searchGames: SearchGamesUseCase
    private let addFavourite: AddFavouriteUseCase
    private let authService: any AuthService

    nonisolated(unsafe) private var searchTask: Task<Void, Never>?
    nonisolated(unsafe) private var errorTask: Task<Void, Never>?

    init(
        searchGames: SearchGamesUseCase,
        addFavourite: AddFavouriteUseCase,
        authService: any AuthService
    ) {
        self.searchGames = searchGames
        self.addFavourite = addFavourite
        self.authService = authService
    }

    func searchQueryChanged(_ query: String) {
        searchTask?.cancel()
        guard query.count >= 2 else {
            state.search = .idle
            return
        }
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                state.search = .loading
                let results = try await searchGames(query)
                state.search = .loaded(results)
            } catch is CancellationError {
            } catch let error as AppError {
                state.search = .failed(error)
            } catch {
                state.search = .failed(.unknown(error.localizedDescription))
            }
        }
    }

    func addGame(_ game: Game) {
        guard let userId = authService.currentUserId else { return }
        Task {
            do {
                try await addFavourite(game: game, userId: userId)
                state.addedGameIds.insert(game.id)
                state.addError = nil
            } catch let error as AppError {
                state.addError = error
                scheduleErrorClear()
            } catch {
                state.addError = .unknown(error.localizedDescription)
                scheduleErrorClear()
            }
        }
    }

    private func scheduleErrorClear() {
        errorTask?.cancel()
        errorTask = Task {
            try? await Task.sleep(for: .seconds(3))
            state.addError = nil
        }
    }

    deinit {
        searchTask?.cancel()
        errorTask?.cancel()
    }
}
