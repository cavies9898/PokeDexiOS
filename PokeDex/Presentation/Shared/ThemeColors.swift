import SwiftUI

enum ThemeColors {
    static let appBlue = Color(hex: 0x2563EB)
    static let skyBlue = Color(hex: 0x38BDF8)
    static let accentRed = Color(hex: 0xE53935)
    static let goodGreen = Color(hex: 0x2E7D32)
    static let badRed = Color(hex: 0xD62A2A)
    static let screenBackground = Color(hex: 0xF0F0F8)
    static let divider = Color(hex: 0xF0F0F8)
    static let labelGray = Color(hex: 0x8A8A8E)
    static let ink = Color(hex: 0x1C1C1E)
    static let tileBackground = Color(hex: 0xF5F6FA)
    static let statTrack = Color(hex: 0xEDEDED)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }

    var luminanceComponents: (red: Double, green: Double, blue: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
    }

    func readableOn() -> Color {
        let components = luminanceComponents
        let luminance = 0.299 * components.red + 0.587 * components.green + 0.114 * components.blue
        return luminance > 0.6 ? ThemeColors.ink : .white
    }

    func dimmed(_ factor: Double) -> Color {
        let components = luminanceComponents
        return Color(
            red: components.red * factor,
            green: components.green * factor,
            blue: components.blue * factor
        )
    }
}
