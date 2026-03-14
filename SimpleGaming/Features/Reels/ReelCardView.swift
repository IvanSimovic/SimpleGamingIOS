import Kingfisher
import SwiftUI

struct ReelCardView: View {
    let state: ReelCardState
    let isFavourite: Bool
    let onToggleFavourite: () -> Void

    @State private var screenshotStartIndex = 0
    @State private var showingScreenshot = false

    private let topScrimEnd = UnitPoint(x: 0.5, y: 0.2)
    private let bottomScrimStart = UnitPoint(x: 0.5, y: 0.35)


    var body: some View {
        ZStack {
            Color.appBackground
            switch state {
            case .loading:
                loadingSkeleton
            case .loaded(let game):
                loadedCard(game)
            case .failed:
                Text("reels_card_failed")
                    .font(AppFont.body2)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .fullScreenCover(isPresented: $showingScreenshot) {
            if case .loaded(let game) = state {
                FullScreenImageViewer(
                    images: game.screenshotUrls,
                    initialIndex: screenshotStartIndex,
                    onDismiss: { showingScreenshot = false }
                )
            }
        }
    }

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()
            skeletonBlock(width: 200, height: 28)
            skeletonBlock(width: 300, height: 14)
            skeletonBlock(width: 250, height: 14)
            skeletonBlock(width: 160, height: 14)
        }
        .padding(24)
    }

    private func skeletonBlock(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.appSurface)
            .frame(width: width, height: height)
    }

    private func loadedCard(_ game: ReelGame) -> some View {
        ZStack(alignment: .bottom) {
            heroImage(game.heroImageUrl)
            topScrim
            bottomScrim
            cardInfoOverlay(game)
        }
        .overlay(alignment: .topTrailing) {
            heartButton
                .padding(.top, 90)
                .padding(.trailing, 16)
        }
    }

    private func heroImage(_ url: String?) -> some View {
        GeometryReader { proxy in
            KFImage(URL(string: url ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }

    private var topScrim: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.55), .clear],
            startPoint: .top,
            endPoint: topScrimEnd
        )
        .allowsHitTesting(false)
    }

    private var bottomScrim: some View {
        LinearGradient(
            colors: [.clear, Color.black.opacity(0.88)],
            startPoint: bottomScrimStart,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var heartButton: some View {
        Button(action: onToggleFavourite) {
            Image(systemName: isFavourite ? "heart.fill" : "heart")
                .font(.system(size: 26))
                .foregroundStyle(isFavourite ? Color.favouriteActive : .white)
                .padding(12)
                .background(Color.black.opacity(0.35), in: Circle())
        }
        .accessibilityLabel(Text(isFavourite ? "accessibility_remove_from_favourites" : "accessibility_add_to_favourites"))
    }

    private func cardInfoOverlay(_ game: ReelGame) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            metacriticRatingRow(game)

            Text(game.name)
                .font(AppFont.head4)
                .foregroundStyle(.white)
                .lineLimit(2)

            if !game.genres.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(game.genres.prefix(3)), id: \.self) { chip($0) }
                }
            }

            if let desc = game.description, !desc.isEmpty {
                Text(desc)
                    .font(AppFont.body2)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(3)
            }

            if !game.screenshotUrls.isEmpty {
                screenshotRow(game.screenshotUrls)
            }

            platformRow(game)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 90)
    }

    @ViewBuilder
    private func metacriticRatingRow(_ game: ReelGame) -> some View {
        if game.metacriticScore != nil || (game.rating ?? 0) > 0 {
            HStack(spacing: 12) {
                if let score = game.metacriticScore { metacriticBadge(score) }
                if let rating = game.rating, rating > 0 {
                    Text(String(format: String(localized: "reels_rating_format"), rating))
                        .font(AppFont.body2)
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func metacriticBadge(_ score: Int) -> some View {
        Text("\(score)")
            .font(AppFont.body6)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(metacriticColor(score), in: RoundedRectangle(cornerRadius: 4))
    }

    private func metacriticColor(_ score: Int) -> Color {
        if score >= 75 { return Color.metacriticGreen }
        if score >= 50 { return Color.metacriticYellow }
        return Color.metacriticRed
    }

    private func screenshotRow(_ urls: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(urls.indices, id: \.self) { index in
                    KFImage(URL(string: urls[index]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 68)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            screenshotStartIndex = index
                            showingScreenshot = true
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func platformRow(_ game: ReelGame) -> some View {
        if (game.playtime ?? 0) > 0 || !game.platforms.isEmpty {
            HStack(spacing: 12) {
                if let playtime = game.playtime, playtime > 0 {
                    Text(String(format: String(localized: "reels_playtime_format"), playtime))
                        .font(AppFont.body3)
                        .foregroundStyle(.white.opacity(0.75))
                }
                ForEach(Array(game.platforms.prefix(4)), id: \.self) { chip($0) }
            }
        }
    }

    private func chip(_ label: String) -> some View {
        Text(label)
            .font(AppFont.body3)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.18), in: Capsule())
    }
}
