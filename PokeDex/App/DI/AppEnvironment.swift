import Foundation
import Observation

@MainActor
@Observable
final class AppEnvironment {
    let getPokemons: GetPokemonsUseCase
    let getPokemonDetail: GetPokemonDetailUseCase
    let getCategories: GetCategoriesUseCase
    let getFavorites: GetFavoritesUseCase
    let toggleFavorite: ToggleFavoriteUseCase
    let getTeams: GetTeamsUseCase
    let createTeam: CreateTeamUseCase
    let renameTeam: RenameTeamUseCase
    let deleteTeam: DeleteTeamUseCase
    let getTeamPokemons: GetTeamPokemonsUseCase
    let savePokemon: SavePokemonUseCase
    let removePokemon: RemovePokemonUseCase
    let getTeamCoverage: GetTeamCoverageUseCase
    let getTeamStats: GetTeamStatsUseCase
    let analyzeTeam: AnalyzeTeamUseCase
    let observeDarkMode: ObserveDarkModeUseCase
    let setDarkMode: SetDarkModeUseCase

    init() throws {
        let pokedexDatabase = try PokedexDatabase()
        let userDatabase = try UserDatabase()

        let pokemonRepository = PokemonRepositoryImpl(database: pokedexDatabase)
        let categoriesRepository = CategoriesRepositoryImpl(database: pokedexDatabase)
        let favoriteRepository = FavoriteRepositoryImpl(database: userDatabase)
        let teamRepository = TeamRepositoryImpl(database: userDatabase)
        let pokemonTeamRepository = PokemonTeamRepositoryImpl(database: userDatabase)
        let themeRepository = ThemeRepositoryImpl()

        getPokemons = GetPokemonsUseCase(
            pokemonRepository: pokemonRepository,
            favoriteRepository: favoriteRepository
        )
        getPokemonDetail = GetPokemonDetailUseCase(repository: pokemonRepository)
        getCategories = GetCategoriesUseCase(repository: categoriesRepository)
        getFavorites = GetFavoritesUseCase(
            pokemonRepository: pokemonRepository,
            favoriteRepository: favoriteRepository
        )
        toggleFavorite = ToggleFavoriteUseCase(repository: favoriteRepository)
        getTeams = GetTeamsUseCase(repository: teamRepository)
        createTeam = CreateTeamUseCase(repository: teamRepository)
        renameTeam = RenameTeamUseCase(repository: teamRepository)
        deleteTeam = DeleteTeamUseCase(repository: teamRepository)
        getTeamPokemons = GetTeamPokemonsUseCase(repository: pokemonTeamRepository)
        savePokemon = SavePokemonUseCase(repository: pokemonTeamRepository)
        removePokemon = RemovePokemonUseCase(repository: pokemonTeamRepository)
        getTeamCoverage = GetTeamCoverageUseCase(repository: pokemonRepository)
        getTeamStats = GetTeamStatsUseCase()
        analyzeTeam = AnalyzeTeamUseCase()
        observeDarkMode = ObserveDarkModeUseCase(repository: themeRepository)
        setDarkMode = SetDarkModeUseCase(repository: themeRepository)
    }

    func makeCoordinator() -> AppCoordinator {
        AppCoordinator()
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getPokemons: getPokemons,
            toggleFavorite: toggleFavorite,
            getCategories: getCategories
        )
    }

    func makeDetailViewModel(id: Int) -> PokemonDetailViewModel {
        PokemonDetailViewModel(
            id: id,
            getPokemonDetail: getPokemonDetail,
            getFavorites: getFavorites,
            toggleFavorite: toggleFavorite
        )
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            getFavorites: getFavorites,
            toggleFavorite: toggleFavorite
        )
    }

    func makeTeamsViewModel() -> TeamsViewModel {
        TeamsViewModel(
            getTeams: getTeams,
            createTeam: createTeam,
            renameTeam: renameTeam,
            deleteTeam: deleteTeam
        )
    }

    func makeTeamBuilderViewModel(idTeam: Int) -> TeamBuilderViewModel {
        TeamBuilderViewModel(
            idTeam: idTeam,
            getPokemons: getPokemons,
            getTeamPokemons: getTeamPokemons,
            savePokemon: savePokemon,
            removePokemon: removePokemon
        )
    }

    func makeTeamStatsViewModel() -> TeamStatsViewModel {
        TeamStatsViewModel(getTeamStats: getTeamStats)
    }

    func makeTeamCoverageViewModel() -> TeamCoverageViewModel {
        TeamCoverageViewModel(getTeamCoverage: getTeamCoverage)
    }

    func makeTeamAnalysisViewModel() -> TeamAnalysisViewModel {
        TeamAnalysisViewModel(analyzeTeam: analyzeTeam)
    }
}
