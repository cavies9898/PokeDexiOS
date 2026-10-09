import Foundation

enum DomainError: LocalizedError, Equatable {
    case pokemonNotFound
    case emptyTeamName
    case teamFull(count: Int)
    case duplicatePokemon
    case pokemonNotInTeam
    case coverageFailed
    case databaseUnavailable

    var errorDescription: String? {
        switch self {
        case .pokemonNotFound:
            "Pokémon no encontrado"
        case .emptyTeamName:
            "El nombre no puede estar vacío"
        case .teamFull(let count):
            "El equipo ya tiene \(count) Pokémon"
        case .duplicatePokemon:
            "Pokémon duplicado"
        case .pokemonNotInTeam:
            "Pokémon no encontrado en el equipo"
        case .coverageFailed:
            "No se pudo calcular la cobertura"
        case .databaseUnavailable:
            "No se pudo abrir la base de datos"
        }
    }
}
