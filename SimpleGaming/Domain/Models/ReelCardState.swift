enum ReelCardState: Sendable, Equatable, Identifiable {
    case loading(id: Int)
    case loaded(ReelGame)
    case failed(id: Int, AppError)

    var id: Int {
        switch self {
        case .loading(let id): id
        case .loaded(let game): game.id
        case .failed(let id, _): id
        }
    }
}
