import SwiftUI

// Typography token hierarchy mapped from Android ExtendedTypography.
// sp values translate 1:1 to pt on iOS (same logical size at default display scale).
enum AppFont {
    static let head1 = Font.system(size: 40, weight: .bold)
    static let head2 = Font.system(size: 32, weight: .bold)
    static let head3 = Font.system(size: 24, weight: .semibold)
    static let head4 = Font.system(size: 20, weight: .semibold)
    static let head5 = Font.system(size: 18, weight: .medium)
    static let body1 = Font.system(size: 16, weight: .regular)
    static let body2 = Font.system(size: 14, weight: .regular)
    static let body3 = Font.system(size: 12, weight: .regular)
    static let body4 = Font.system(size: 16, weight: .light)
    static let body5 = Font.system(size: 14, weight: .light)
    static let body6 = Font.system(size: 14, weight: .medium)
    static let body7 = Font.system(size: 10, weight: .bold)
    static let iconRegular = Font.system(size: 22)
    static let iconSemibold = Font.system(size: 22, weight: .semibold)
}
