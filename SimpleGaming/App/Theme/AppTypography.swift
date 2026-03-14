import SwiftUI
import UIKit

enum AppFont {
    static let head1 = Font(UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 40, weight: .bold)))
    static let head2 = Font(UIFontMetrics(forTextStyle: .title1).scaledFont(for: .systemFont(ofSize: 32, weight: .bold)))
    static let head3 = Font(UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 24, weight: .semibold)))
    static let head4 = Font(UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold)))
    static let head5 = Font(UIFontMetrics(forTextStyle: .headline).scaledFont(for: .systemFont(ofSize: 18, weight: .medium)))
    static let body1 = Font(UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .regular)))
    static let body2 = Font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 14, weight: .regular)))
    static let body3 = Font(UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .regular)))
    static let body4 = Font(UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .light)))
    static let body5 = Font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 14, weight: .light)))
    static let body6 = Font(UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 14, weight: .medium)))
    static let body7 = Font(UIFontMetrics(forTextStyle: .caption2).scaledFont(for: .systemFont(ofSize: 10, weight: .bold)))
    static let iconRegular = Font.system(size: 22)
    static let iconSemibold = Font.system(size: 22, weight: .semibold)
}
