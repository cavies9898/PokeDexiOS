import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    struct UiState {
        var isLoading = true
        var pokemons: [Pokemon] = []
        var filteredPokemons: [Pokemon] = []
        var categoryOptions: [String] = []
        var categorySelected: [String] = []
        var currentFilterItem: FilterItem?
        var searchQuery = ""
        var sortAscending: Bool?
        var shouldResetScroll = false
        var scrollResetSignal = 0
        var firstVisibleIndex = 0
        var error: String?

        mutating func resetScroll() {
            shouldResetScroll = true
            scrollResetSignal += 1
        }
    }

    private let getPokemons: GetPokemonsUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let getCategories: GetCategoriesUseCase

    var uiState = UiState()

    private var cachedCategories: Categories?
    nonisolated(unsafe) private var observeTask: Task<Void, Never>?

    init(
        getPokemons: GetPokemonsUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        getCategories: GetCategoriesUseCase
    ) {
        self.getPokemons = getPokemons
        self.toggleFavorite = toggleFavorite
        self.getCategories = getCategories
        observePokemons()
    }

    deinit {
        observeTask?.cancel()
    }

    private func observePokemons() {
        observeTask = Task { [weak self] in
            guard let stream = await self?.getPokemons() else { return }
            var receivedAny = false
            for await list in stream {
                if Task.isCancelled { return }
                receivedAny = true
                self?.uiState.pokemons = list
                self?.uiState.isLoading = false
                self?.uiState.error = nil
                self?.refreshList()
            }
            if !receivedAny, let self, self.uiState.error == nil {
                self.uiState.isLoading = false
                self.uiState.error = "Error al cargar los Pokémon"
            }
        }
    }

    func onFavoriteClick(_ pokemon: Pokemon) {
        Task { await toggleFavorite(pokemon) }
    }

    func onSearchQueryChanged(_ query: String) {
        uiState.searchQuery = query
        uiState.resetScroll()
        refreshList()
    }

    func onFilterItemSelected(_ item: FilterItem) {
        let previous = uiState.currentFilterItem
        let sameFilter = item == previous

        uiState.currentFilterItem = item
        uiState.resetScroll()
        if !sameFilter {
            uiState.categorySelected = []
            uiState.categoryOptions = []
        }
        uiState.sortAscending = FilterPipeline.defaultDirection(
            for: item,
            current: uiState.sortAscending
        )

        if item.hasOptions, !sameFilter {
            Task {
                let options = await categoryValues(item)
                uiState.categoryOptions = options
            }
        }

        refreshList()
    }

    func filterByCategory(_ selected: [String]) {
        uiState.categorySelected = selected
        uiState.resetScroll()
        refreshList()
    }

    func sortAscending() {
        uiState.sortAscending = true
        uiState.resetScroll()
        refreshList()
    }

    func sortDescending() {
        uiState.sortAscending = false
        uiState.resetScroll()
        refreshList()
    }

    func consumeScrollResetFlag() {
        uiState.shouldResetScroll = false
    }

    func retry() {
        uiState.isLoading = true
        uiState.error = nil
        observePokemons()
    }

    private func refreshList() {
        uiState.filteredPokemons = FilterPipeline.apply(
            pokemons: uiState.pokemons,
            searchQuery: uiState.searchQuery,
            filter: uiState.currentFilterItem,
            selectedCategories: uiState.categorySelected,
            sortAscending: uiState.sortAscending
        )
    }

    private func categoryValues(_ item: FilterItem) async -> [String] {
        if let cached = cachedCategories {
            return item.categoryValues(cached)
        }
        guard let categories = try? await getCategories() else { return [] }
        cachedCategories = categories
        return item.categoryValues(categories)
    }
}
