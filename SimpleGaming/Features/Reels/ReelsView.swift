import SwiftUI

struct ReelsView: View {
    @State private var viewModel: ReelsViewModel
    @State private var scrollPosition: Int?

    init(
        fetchReelIds: FetchReelIdsUseCase,
        fetchReelGame: FetchReelGameUseCase,
        fetchFavourites: FetchFavouritesUseCase,
        addFavourite: AddFavouriteUseCase,
        removeFavourite: RemoveFavouriteUseCase,
        authService: any AuthService
    ) {
        _viewModel = State(initialValue: ReelsViewModel(
            fetchReelIds: fetchReelIds,
            fetchReelGame: fetchReelGame,
            fetchFavourites: fetchFavourites,
            addFavourite: addFavourite,
            removeFavourite: removeFavourite,
            authService: authService
        ))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            content
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .tint(Color.textMuted)
        case .empty:
            Text("reels_empty")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
        case .failed(let error):
            Text(error.errorDescription ?? String(localized: "error_generic"))
                .font(AppFont.body1)
                .foregroundStyle(Color.appError)
                .multilineTextAlignment(.center)
                .padding()
        case .ready(let cards, let favouriteIds):
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        ReelCardView(
                            state: card,
                            isFavourite: favouriteIds.contains(card.id),
                            onToggleFavourite: {
                                if case .loaded(let game) = card {
                                    viewModel.toggleFavourite(game: game)
                                }
                            }
                        )
                        .containerRelativeFrame([.horizontal, .vertical])
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            .ignoresSafeArea()
            .onChange(of: scrollPosition) { _, newIndex in
                if let index = newIndex {
                    viewModel.didPageTo(index: index)
                }
            }
        }
    }
}
