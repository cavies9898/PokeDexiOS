import Foundation
import Testing
@testable import PokeDex

private final class MockPokemonTeamRepository: PokemonTeamRepository, @unchecked Sendable {
    var outcome: SavePokemonOutcome = .saved
    var removedCount = 1
    private(set) var savedPokemon: [Pokemon] = []

    func observeTeam(idTeam: Int) async -> AsyncStream<[Pokemon]> {
        AsyncStream { $0.finish() }
    }

    func team(idTeam: Int) async throws -> [Pokemon] {
        savedPokemon
    }

    func savePokemon(_ pokemon: Pokemon, idTeam: Int) async throws -> SavePokemonOutcome {
        savedPokemon.append(pokemon)
        return outcome
    }

    func deletePokemon(idPokemon: Int, idTeam: Int) async throws -> Int {
        removedCount
    }
}

private final class MockTeamRepository: TeamRepository, @unchecked Sendable {
    private(set) var createdNames: [String] = []

    func observeTeams() async -> AsyncStream<[Team]> {
        AsyncStream { $0.finish() }
    }

    func createTeam(name: String) async throws -> Int {
        createdNames.append(name)
        return createdNames.count
    }

    func renameTeam(id: Int, name: String) async throws {}

    func deleteTeam(id: Int) async throws {}
}

struct TeamValidationTests {
    @Test
    func saveFailsWhenTeamIsFull() async {
        let repository = MockPokemonTeamRepository()
        repository.outcome = .teamFull
        let useCase = SavePokemonUseCase(repository: repository)

        let result = await useCase(Pokemon(id: 25, name: "pikachu"), idTeam: 1)

        guard case .failure(let error) = result else {
            Issue.record("Expected failure for full team")
            return
        }
        #expect((error as? DomainError) == .teamFull(count: 6))
        #expect(error.localizedDescription == "El equipo ya tiene 6 Pokémon")
    }

    @Test
    func saveFailsOnDuplicatePokemon() async {
        let repository = MockPokemonTeamRepository()
        repository.outcome = .duplicate
        let useCase = SavePokemonUseCase(repository: repository)

        let result = await useCase(Pokemon(id: 25, name: "pikachu"), idTeam: 1)

        guard case .failure(let error) = result else {
            Issue.record("Expected failure for duplicate")
            return
        }
        #expect((error as? DomainError) == .duplicatePokemon)
        #expect(error.localizedDescription == "Pokémon duplicado")
    }

    @Test
    func saveSucceedsWhenOutcomeIsSaved() async {
        let repository = MockPokemonTeamRepository()
        let useCase = SavePokemonUseCase(repository: repository)

        let result = await useCase(Pokemon(id: 25, name: "pikachu"), idTeam: 1)

        guard case .success = result else {
            Issue.record("Expected success")
            return
        }
        #expect(repository.savedPokemon.map(\.id) == [25])
    }

    @Test
    func removeFailsWhenPokemonIsNotInTheTeam() async {
        let repository = MockPokemonTeamRepository()
        repository.removedCount = 0
        let useCase = RemovePokemonUseCase(repository: repository)

        let result = await useCase(idPokemon: 25, idTeam: 1)

        guard case .failure(let error) = result else {
            Issue.record("Expected failure for missing member")
            return
        }
        #expect((error as? DomainError) == .pokemonNotInTeam)
        #expect(error.localizedDescription == "Pokémon no encontrado en el equipo")
    }

    @Test
    func removeSucceedsWhenRepositoryDeletesARow() async {
        let repository = MockPokemonTeamRepository()
        repository.removedCount = 1
        let useCase = RemovePokemonUseCase(repository: repository)

        let result = await useCase(idPokemon: 25, idTeam: 1)

        guard case .success = result else {
            Issue.record("Expected success")
            return
        }
    }

    @Test
    func createTeamRejectsBlankName() async {
        let repository = MockTeamRepository()
        let useCase = CreateTeamUseCase(repository: repository)

        let result = await useCase(name: "   ")

        guard case .failure(let error) = result else {
            Issue.record("Expected failure for blank name")
            return
        }
        #expect((error as? DomainError) == .emptyTeamName)
        #expect(error.localizedDescription == "El nombre no puede estar vacío")
        #expect(repository.createdNames.isEmpty)
    }

    @Test
    func createTeamTrimsNameBeforePersisting() async {
        let repository = MockTeamRepository()
        let useCase = CreateTeamUseCase(repository: repository)

        let result = await useCase(name: "  Mi Equipo  ")

        guard case .success(let id) = result else {
            Issue.record("Expected success")
            return
        }
        #expect(id == 1)
        #expect(repository.createdNames == ["Mi Equipo"])
    }

    @Test
    func errorMessagesMatchSpanishSpecifications() {
        #expect(DomainError.pokemonNotFound.errorDescription == "Pokémon no encontrado")
        #expect(DomainError.emptyTeamName.errorDescription == "El nombre no puede estar vacío")
        #expect(DomainError.teamFull(count: 6).errorDescription == "El equipo ya tiene 6 Pokémon")
        #expect(DomainError.duplicatePokemon.errorDescription == "Pokémon duplicado")
        #expect(DomainError.pokemonNotInTeam.errorDescription == "Pokémon no encontrado en el equipo")
        #expect(DomainError.coverageFailed.errorDescription == "No se pudo calcular la cobertura")
        #expect(DomainError.databaseUnavailable.errorDescription == "No se pudo abrir la base de datos")
    }
}
