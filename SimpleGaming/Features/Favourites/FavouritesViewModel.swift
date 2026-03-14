import Foundation

enum FavouritesState: Sendable, Equatable {
    case loading
    case loaded([FavouriteGame])
    case failed(AppError)
}

@Observable
@MainActor
final class FavouritesViewModel {
    private(set) var state: FavouritesState = .loading

    private let fetchFavourites: FetchFavouritesUseCase
    private let removeFavourite: RemoveFavouriteUseCase
    private let authService: any AuthService
    private(set) var removeError: AppError?
    nonisolated(unsafe) private var removeTask: Task<Void, Never>?
    nonisolated(unsafe) private var removeErrorTask: Task<Void, Never>?

    init(
        fetchFavourites: FetchFavouritesUseCase,
        removeFavourite: RemoveFavouriteUseCase,
        authService: any AuthService
    ) {
        self.fetchFavourites = fetchFavourites
        self.removeFavourite = removeFavourite
        self.authService = authService
    }

    func observe() async {
        guard let userId = authService.currentUserId else {
            state = .failed(.unauthenticated)
            return
        }
        for await games in fetchFavourites(userId: userId) {
            state = .loaded(games)
        }
        if case .loading = state {
            state = .failed(.firestoreError(String(localized: "error_stream_terminated")))
        }
    }

    func remove(gameId: Int) {
        guard let userId = authService.currentUserId else { return }
        removeTask = Task {
            do {
                try await removeFavourite(gameId: gameId, userId: userId)
            } catch let error as AppError {
                removeError = error
                scheduleErrorClear()
            } catch {
                removeError = .unknown(error.localizedDescription)
                scheduleErrorClear()
            }
        }
    }

    private func scheduleErrorClear() {
        removeErrorTask?.cancel()
        removeErrorTask = Task {
            try? await Task.sleep(for: .seconds(3))
            removeError = nil
        }
    }

    deinit {
        removeTask?.cancel()
        removeErrorTask?.cancel()
    }
}
