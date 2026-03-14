import Kingfisher
import SwiftUI

struct FavouritesView: View {
    @State private var viewModel: FavouritesViewModel
    @State private var selectedGameId: Int?
    @State private var showAddGame = false
    @State private var shimmerPhase: CGFloat = -0.6

    private let searchGames: SearchGamesUseCase
    private let addFavourite: AddFavouriteUseCase
    private let authService: any AuthService

    init(
        fetchFavourites: FetchFavouritesUseCase,
        removeFavourite: RemoveFavouriteUseCase,
        searchGames: SearchGamesUseCase,
        addFavourite: AddFavouriteUseCase,
        authService: any AuthService
    ) {
        _viewModel = State(initialValue: FavouritesViewModel(
            fetchFavourites: fetchFavourites,
            removeFavourite: removeFavourite,
            authService: authService
        ))
        self.searchGames = searchGames
        self.addFavourite = addFavourite
        self.authService = authService
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                content
            }
            .navigationTitle("tab_favourites")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.observe() }
        .sheet(isPresented: $showAddGame) {
            AddGameView(
                searchGames: searchGames,
                addFavourite: addFavourite,
                authService: authService
            )
        }
        .toast(message: viewModel.removeError?.errorDescription)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            favouritesShimmer
        case .failed:
            Text("favourites_error")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
        case .loaded(let games) where games.isEmpty:
            Text("favourites_empty")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
        case .loaded(let games):
            gameGrid(games)
        }
    }

    private var favouritesShimmer: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppDimen.gridSpacing
            ) {
                ForEach(0..<6, id: \.self) { _ in
                    ShimmerView(phase: shimmerPhase)
                        .aspectRatio(0.75, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: AppDimen.cardCornerRadius))
                }
            }
            .padding(.horizontal, AppDimen.screenPadding)
            .padding(.top, AppDimen.spaceS)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                shimmerPhase = 1.3
            }
        }
    }

    private func gameGrid(_ games: [FavouriteGame]) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppDimen.gridSpacing
            ) {
                ForEach(games) { game in
                    GameCell(
                        game: game,
                        isSelected: game.id == selectedGameId,
                        isOtherSelected: selectedGameId != nil && game.id != selectedGameId,
                        onLongPress: { selectedGameId = game.id },
                        onDelete: {
                            viewModel.remove(gameId: game.id)
                            selectedGameId = nil
                        },
                        onCancel: { selectedGameId = nil }
                    )
                }
            }
            .padding(.horizontal, AppDimen.screenPadding)
            .padding(.top, AppDimen.spaceS)
            .padding(.bottom, AppDimen.fabClearance)
        }
        .onChange(of: games) { _, newGames in
            if let id = selectedGameId, !newGames.contains(where: { $0.id == id }) {
                selectedGameId = nil
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddGame = true
            } label: {
                Image(systemName: "plus")
                    .font(AppFont.iconSemibold)
                    .foregroundStyle(Color.onBrand)
                    .frame(width: AppDimen.fabSize, height: AppDimen.fabSize)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .accessibilityLabel(Text("accessibility_add_game"))
            .padding(.trailing, AppDimen.fabPadding)
            .padding(.bottom, AppDimen.fabPadding)
        }
    }
}

private struct GameCell: View {
    let game: FavouriteGame
    let isSelected: Bool
    let isOtherSelected: Bool
    let onLongPress: () -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var shakeAmount: CGFloat = 0

    var body: some View {
        Color.appSurface
            .aspectRatio(0.75, contentMode: .fit)
            .overlay(imageContent.allowsHitTesting(false))
            .overlay(dimContent.allowsHitTesting(false))
            .overlay(deleteContent)
            .clipShape(RoundedRectangle(cornerRadius: AppDimen.cardCornerRadius))
            .modifier(ShakeEffect(animatableData: shakeAmount))
            .onLongPressGesture { onLongPress() }
            .accessibilityLabel(game.name)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: Text("accessibility_delete_game")) { onLongPress() }
            .onChange(of: isSelected) { _, selected in
                if selected {
                    withAnimation(.easeOut(duration: 0.4)) {
                        shakeAmount += 1
                    }
                }
            }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let url = game.imageUrl, !url.isEmpty {
            KFImage(URL(string: url))
                .resizable()
                .scaledToFill()
        } else {
            Text(game.name)
                .font(AppFont.body2)
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(AppDimen.spaceM)
        }
    }

    @ViewBuilder
    private var dimContent: some View {
        if isOtherSelected {
            Color.overlayDark
                .animation(.easeInOut(duration: 0.2), value: isOtherSelected)
        }
    }

    @ViewBuilder
    private var deleteContent: some View {
        if isSelected {
            deleteOverlay
        }
    }

    private var deleteOverlay: some View {
        ZStack {
            Button(action: onDelete) {
                Text("favourites_remove")
                    .font(AppFont.body2)
                    .foregroundStyle(Color.appError)
                    .padding(.horizontal, AppDimen.spaceL)
                    .padding(.vertical, AppDimen.spaceS)
                    .background(Color.overlayDark)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            VStack {
                Spacer()
                Button(action: onCancel) {
                    Text("favourites_cancel")
                        .font(AppFont.body3)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppDimen.spaceL)
                        .padding(.vertical, AppDimen.spaceS)
                        .background(Color.overlayDark)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.bottom, AppDimen.listRowVerticalPadding)
            }
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 8 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
