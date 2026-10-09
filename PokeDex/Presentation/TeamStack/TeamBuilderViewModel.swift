import Foundation
import Observation

@MainActor
@Observable
final class TeamBuilderViewModel {
    struct UiState {
        var idTeam = 0
        var pokemonTeam: [Pokemon] = []
        var pokemons: [Pokemon] = []
        var filteredPokemons: [Pokemon] = []
        var searchQuery = ""
        var error: String?
        var message: String?
    }

    private let getPokemons: GetPokemonsUseCase
    private let getTeamPokemons: GetTeamPokemonsUseCase
    private let savePokemon: SavePokemonUseCase
    private let removePokemon: RemovePokemonUseCase

    var uiState = UiState()

    nonisolated(unsafe) private var pokemonsTask: Task<Void, Never>?
    nonisolated(unsafe) private var teamTask: Task<Void, Never>?

    init(
        idTeam: Int,
        getPokemons: GetPokemonsUseCase,
        getTeamPokemons: GetTeamPokemonsUseCase,
        savePokemon: SavePokemonUseCase,
        removePokemon: RemovePokemonUseCase
    ) {
        self.getPokemons = getPokemons
        self.getTeamPokemons = getTeamPokemons
        self.savePokemon = savePokemon
        self.removePokemon = removePokemon
        uiState.idTeam = idTeam
        observePokemons()
        observeTeam()
    }

    deinit {
        pokemonsTask?.cancel()
        teamTask?.cancel()
    }

    func onSearchQueryChanged(_ query: String) {
        uiState.searchQuery = query
        uiState.filteredPokemons = filter(uiState.pokemons, query)
    }

    func addPokemon(_ pokemon: Pokemon) {
        let idTeam = uiState.idTeam
        guard idTeam > 0 else {
            uiState.error = "Debes crear un equipo antes de agregar Pokémon"
            return
        }
        Task {
            let result = await self.savePokemon(pokemon, idTeam: idTeam)
            switch result {
            case .success:
                self.uiState.message = "\(pokemon.name) agregado al equipo"
                self.uiState.error = nil
            case .failure(let error):
                self.uiState.error = error.localizedDescription
            }
        }
    }

    func removePokemon(_ pokemon: Pokemon) {
        let idTeam = uiState.idTeam
        guard idTeam > 0 else { return }
        Task {
            let result = await self.removePokemon(idPokemon: pokemon.id, idTeam: idTeam)
            switch result {
            case .success:
                self.uiState.message = "\(pokemon.name) eliminado del equipo"
                self.uiState.error = nil
            case .failure(let error):
                self.uiState.error = error.localizedDescription
            }
        }
    }

    func onErrorShown() {
        uiState.error = nil
        uiState.message = nil
    }

    private func observePokemons() {
        pokemonsTask?.cancel()
        pokemonsTask = Task { [weak self] in
            guard let self else { return }
            let stream = await self.getPokemons()
            for await list in stream {
                if Task.isCancelled { return }
                self.uiState.pokemons = list
                self.uiState.filteredPokemons = self.filter(list, self.uiState.searchQuery)
            }
        }
    }

    private func observeTeam() {
        teamTask?.cancel()
        teamTask = Task { [weak self] in
            guard let self else { return }
            let stream = await self.getTeamPokemons(idTeam: self.uiState.idTeam)
            for await pokemons in stream {
                if Task.isCancelled { return }
                self.uiState.pokemonTeam = pokemons
            }
        }
    }

    private func filter(_ list: [Pokemon], _ query: String) -> [Pokemon] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return list }
        return list.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
