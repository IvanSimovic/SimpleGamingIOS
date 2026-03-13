struct FetchFavouritesUseCase: Sendable {
    let fetch: @Sendable (String) -> AsyncStream<[FavouriteGame]>

    func callAsFunction(userId: String) -> AsyncStream<[FavouriteGame]> {
        fetch(userId)
    }
}
