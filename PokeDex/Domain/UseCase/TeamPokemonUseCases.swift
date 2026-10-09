import Foundation

struct GetTeamPokemonsUseCase: Sendable {
    private let repository: any PokemonTeamRepository

    init(repository: any PokemonTeamRepository) {
        self.repository = repository
    }

    func callAsFunction(idTeam: Int) async -> AsyncStream<[Pokemon]> {
        await repository.observeTeam(idTeam: idTeam)
    }
}

struct SavePokemonUseCase: Sendable {
    private let repository: any PokemonTeamRepository

    init(repository: any PokemonTeamRepository) {
        self.repository = repository
    }

    func callAsFunction(_ pokemon: Pokemon, idTeam: Int) async -> Result<Void, Error> {
        do {
            switch try await repository.savePokemon(pokemon, idTeam: idTeam) {
            case .saved:
                return .success(())
            case .teamFull:
                return .failure(DomainError.teamFull(count: Team.maxPokemon))
            case .duplicate:
                return .failure(DomainError.duplicatePokemon)
            }
        } catch {
            return .failure(error)
        }
    }
}

struct RemovePokemonUseCase: Sendable {
    private let repository: any PokemonTeamRepository

    init(repository: any PokemonTeamRepository) {
        self.repository = repository
    }

    func callAsFunction(idPokemon: Int, idTeam: Int) async -> Result<Void, Error> {
        do {
            let removed = try await repository.deletePokemon(idPokemon: idPokemon, idTeam: idTeam)
            guard removed > 0 else {
                return .failure(DomainError.pokemonNotInTeam)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
