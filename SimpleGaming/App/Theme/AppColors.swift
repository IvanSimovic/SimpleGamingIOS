import SwiftUI

extension Color {
    // MARK: - Brand
    static let brandPrimary = Color.adaptive(light: 0x0061A4, dark: 0x9ECAFF)

    // MARK: - Background
    static let appBackground = Color.adaptive(light: 0xFDFCFF, dark: 0x1A1C1E)
    static let appSurface = Color.adaptive(light: 0xFDFCFF, dark: 0x2D2F31)

    // MARK: - Text
    static let textMain = Color.adaptive(light: 0x1A1C1E, dark: 0xE2E2E6)
    static let textMuted = Color.adaptive(light: 0x74777F, dark: 0x8E9199)

    // MARK: - Semantic
    static let appError = Color.adaptive(light: 0xBA1A1A, dark: 0xFFB4AB)
    static let appSuccess = Color.adaptive(light: 0x2E7D32, dark: 0x81C784)
    static let appWarning = Color.adaptive(light: 0xF9A825, dark: 0xFFF176)
    static let appDivider = Color.adaptive(light: 0xC4C7C8, dark: 0x444748)

    // MARK: - Rating
    static let metacriticGreen = Color(red: 0.298, green: 0.686, blue: 0.314)
    static let metacriticYellow = Color(red: 1.0, green: 0.757, blue: 0.027)
    static let metacriticRed = Color(red: 0.957, green: 0.263, blue: 0.212)

    // MARK: - Interactive
    static let favouriteActive = Color(red: 0.9, green: 0.22, blue: 0.21)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
