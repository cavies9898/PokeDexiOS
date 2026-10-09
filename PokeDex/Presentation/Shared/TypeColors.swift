import SwiftUI

enum TypeColors {
    private static let colors: [String: Color] = [
        "normal": Color(hex: 0xA8A77A),
        "fire": Color(hex: 0xEE8130),
        "water": Color(hex: 0x6390F0),
        "electric": Color(hex: 0xF7D02C),
        "grass": Color(hex: 0x7AC74C),
        "ice": Color(hex: 0x96D9D6),
        "fighting": Color(hex: 0xC22E28),
        "poison": Color(hex: 0xA33EA1),
        "ground": Color(hex: 0xE2BF65),
        "flying": Color(hex: 0xA98FF3),
        "psychic": Color(hex: 0xF95587),
        "bug": Color(hex: 0xA6B91A),
        "rock": Color(hex: 0xB6A136),
        "ghost": Color(hex: 0x735797),
        "dragon": Color(hex: 0x6F35FC),
        "dark": Color(hex: 0x705746),
        "steel": Color(hex: 0xB7B7CE),
        "fairy": Color(hex: 0xD685AD),
    ]

    static func color(for type: String?) -> Color {
        guard let type else { return .gray }
        return colors[type] ?? .gray
    }
}

enum StatPalette {
    static let labels = ["HP", "Ataque", "Defensa", "At. Esp.", "Def. Esp.", "Velocidad"]
    static let radarLabels = ["HP", "ATQ", "DEF", "SPA", "SPD", "VEL"]
    static let colors: [Color] = [
        Color(hex: 0xEF5350),
        Color(hex: 0xFFB300),
        Color(hex: 0x9CCC65),
        Color(hex: 0x42A5F5),
        Color(hex: 0xAB47BC),
        Color(hex: 0xEC407A),
    ]
    static let maxStat = 255
}

enum RolePalette {
    static func color(for role: Role) -> Color {
        switch role {
        case .tank: Color(hex: 0x43A047)
        case .fast: Color(hex: 0x1E88E5)
        case .physical: Color(hex: 0xE53935)
        case .special: Color(hex: 0x8E24AA)
        case .balanced: Color(hex: 0xFB8C00)
        }
    }

    static func icon(for role: Role) -> String {
        switch role {
        case .tank: "shield"
        case .fast: "bolt.speed"
        case .physical: "figure.strengthtraining"
        case .special: "sparkles"
        case .balanced: "chart.line.uptrend.xyaxis"
        }
    }
}
