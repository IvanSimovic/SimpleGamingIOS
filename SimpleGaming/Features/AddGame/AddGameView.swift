import Kingfisher
import SwiftUI

struct AddGameView: View {
    @State private var viewModel: AddGameViewModel
    @State private var query = ""

    init(
        searchGames: SearchGamesUseCase,
        addFavourite: AddFavouriteUseCase,
        authService: any AuthService
    ) {
        _viewModel = State(initialValue: AddGameViewModel(
            searchGames: searchGames,
            addFavourite: addFavourite,
            authService: authService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    searchBar
                    resultsList
                }
            }
            .navigationTitle("add_game_title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(message: viewModel.state.addError?.errorDescription)
    }

    private var searchBar: some View {
        HStack(spacing: AppDimen.spaceS) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.textMuted)
            TextField("add_game_search_placeholder", text: $query)
                .font(AppFont.body1)
                .foregroundStyle(Color.textMain)
                .autocorrectionDisabled()
                .onChange(of: query) { _, newValue in
                    viewModel.searchQueryChanged(newValue)
                }
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.textMuted)
                }
                .accessibilityLabel(Text("accessibility_clear_search"))
            }
        }
        .padding(.horizontal, AppDimen.spaceM)
        .padding(.vertical, AppDimen.searchBarVerticalPadding)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppDimen.searchBarCornerRadius))
        .padding(.horizontal, AppDimen.screenPadding)
        .padding(.vertical, AppDimen.spaceM)
    }

    @ViewBuilder
    private var resultsList: some View {
        switch viewModel.state.search {
        case .idle:
            Spacer()
            Text("add_game_search_hint")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
            Spacer()
        case .loading:
            Spacer()
            ProgressView()
                .tint(Color.textMuted)
            Spacer()
        case .failed:
            Spacer()
            Text("add_game_search_failed")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
            Spacer()
        case .loaded(let games) where games.isEmpty:
            Spacer()
            Text("add_game_no_results")
                .font(AppFont.body1)
                .foregroundStyle(Color.textMuted)
            Spacer()
        case .loaded(let games):
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(games) { game in
                        GameRow(
                            game: game,
                            isAdded: viewModel.state.addedGameIds.contains(game.id),
                            onAdd: { viewModel.addGame(game) }
                        )
                        Divider()
                            .padding(.leading, AppDimen.thumbnailSize + AppDimen.spaceM + AppDimen.spaceS)
                    }
                }
                .padding(.horizontal, AppDimen.screenPadding)
            }
        }
    }
}

private struct GameRow: View {
    let game: Game
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: AppDimen.spaceM) {
            KFImage(URL(string: game.imageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: AppDimen.thumbnailSize, height: AppDimen.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: AppDimen.thumbnailCornerRadius))
                .background(Color.appSurface.clipShape(RoundedRectangle(cornerRadius: AppDimen.thumbnailCornerRadius)))

            Text(game.name)
                .font(AppFont.body1)
                .foregroundStyle(Color.textMain)
                .lineLimit(2)

            Spacer()

            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appSuccess)
                    .font(AppFont.iconRegular)
                    .accessibilityLabel(Text("accessibility_already_added"))
            } else {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.brandPrimary)
                        .font(AppFont.iconRegular)
                }
            }
        }
        .padding(.vertical, AppDimen.listRowVerticalPadding)
    }
}
