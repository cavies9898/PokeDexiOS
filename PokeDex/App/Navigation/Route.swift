import Foundation

enum Route: Hashable {
    case splash
    case home
    case team
    case favorites
    case settings
    case detail(id: Int)
    case teamStack(idTeam: Int?)
}

enum TeamTab: String, CaseIterable, Identifiable {
    case team = "Equipo"
    case stats = "Estadísticas"
    case coverage = "Cobertura"
    case analysis = "Análisis"

    var id: String { rawValue }
}
