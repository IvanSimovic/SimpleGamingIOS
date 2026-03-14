import CoreGraphics

enum AppDimen {
    // MARK: - Spacing Scale
    static let spaceXS: CGFloat = 4
    static let spaceS: CGFloat = 8
    static let spaceM: CGFloat = 12
    static let spaceL: CGFloat = 16
    static let spaceXL: CGFloat = 24

    // MARK: - Screen
    static let screenPadding: CGFloat = 16

    // MARK: - Cards & Grid
    static let cardCornerRadius: CGFloat = 12
    static let gridSpacing: CGFloat = 12

    // MARK: - List Rows
    static let thumbnailSize: CGFloat = 48
    static let thumbnailCornerRadius: CGFloat = 8
    static let listRowVerticalPadding: CGFloat = 10

    // MARK: - Search Bar
    static let searchBarCornerRadius: CGFloat = 10
    static let searchBarVerticalPadding: CGFloat = 10

    // MARK: - FAB
    static let fabSize: CGFloat = 56
    static let fabPadding: CGFloat = 24
    static let fabClearance: CGFloat = 96

    // MARK: - Reels full-screen card
    // Clears the status bar + notch area at the top, and the tab bar + home indicator at the bottom.
    static let reelHeartTopPadding: CGFloat = 90
    static let reelInfoBottomPadding: CGFloat = 90
}
