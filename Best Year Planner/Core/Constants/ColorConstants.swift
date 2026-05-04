import SwiftUI

enum AppColors {
    // Brand colors (same in light/dark)
    static let primary = Color(hex: "4A90D9")
    static let secondary = Color(hex: "7ED321")
    static let accent = Color(hex: "F5A623")

    // Adaptive colors (auto-switch for light/dark)
    static let background = Color(light: Color(hex: "F8F9FA"), dark: Color(hex: "1A1A2E"))
    static let cardBackground = Color(light: Color.white, dark: Color(hex: "16213E"))
    static let textPrimary = Color(light: Color(hex: "2C3E50"), dark: Color(hex: "FFFFFF"))
    static let textSecondary = Color(light: Color(hex: "7F8C8D"), dark: Color(hex: "A0A0A0"))
    static let divider = Color(light: Color(hex: "E0E0E0"), dark: Color(hex: "2C2C4A"))
    static let disabled = Color(light: Color(hex: "BDC3C7"), dark: Color(hex: "4A4A6A"))

    // Dimension colors (vibrant in both modes)
    static let careerDimension = Color(hex: "3498DB")
    static let relationshipDimension = Color(hex: "E74C8C")
    static let growthDimension = Color(hex: "27AE60")

    // Semantic colors
    static let success = Color(hex: "27AE60")
    static let warning = Color(hex: "F39C12")
    static let error = Color(hex: "E74C3C")

    // Keep legacy dark colors for reference
    static let darkBackground = Color(hex: "1A1A2E")
    static let darkCard = Color(hex: "16213E")
    static let darkTextPrimary = Color(hex: "FFFFFF")
    static let darkTextSecondary = Color(hex: "A0A0A0")
}

extension Color {
    /// Create a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
