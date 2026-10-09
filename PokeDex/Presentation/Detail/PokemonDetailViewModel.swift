import Foundation
import Observation

@MainActor
@Observable
final class PokemonDetailViewModel {
    struct UiState {
        var detail: PokemonDetail?
        var isLoading = true
        var error: String?
        var isFavorite = false
    }

    let id: Int
    private let getPokemonDetail: GetPokemonDetailUseCase
    private let getFavorites: GetFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    var uiState = UiState()

    nonisolated(unsafe) private var detailTask: Task<Void, Never>?
    nonisolated(unsafe) private var favoritesTask: Task<Void, Never>?

    init(
        id: Int,
        getPokemonDetail: GetPokemonDetailUseCase,
        getFavorites: GetFavoritesUseCase,
        toggleFavorite: ToggleFavoriteUseCase
    ) {
        self.id = id
        self.getPokemonDetail = getPokemonDetail
        self.getFavorites = getFavorites
        self.toggleFavorite = toggleFavorite
        observeFavorites()
        load()
    }

    deinit {
        detailTask?.cancel()
        favoritesTask?.cancel()
    }

    func load() {
        guard id > 0 else {
            uiState.isLoading = false
            uiState.error = "Pokémon no encontrado"
            return
        }
        uiState.isLoading = true
        uiState.error = nil

        detailTask?.cancel()
        detailTask = Task { [weak self] in
            guard let self else { return }
            let result = await self.getPokemonDetail(id: id)
            guard !Task.isCancelled else { return }
            switch result {
            case .success(let detail):
                self.uiState.detail = detail
                self.uiState.isLoading = false
                self.uiState.error = nil
            case .failure(let error):
                self.uiState.detail = nil
                self.uiState.isLoading = false
                self.uiState.error = error.localizedDescription
            }
        }
    }

    func onRetry() {
        load()
    }

    func onFavoriteClick() {
        guard let detail = uiState.detail else { return }
        Task { await toggleFavorite(detail.pokemon) }
    }

    private func observeFavorites() {
        favoritesTask?.cancel()
        favoritesTask = Task { [weak self] in
            guard let self else { return }
            let stream = await self.getFavorites()
            for await favorites in stream {
                if Task.isCancelled { return }
                self.uiState.isFavorite = favorites.contains { $0.id == self.id }
            }
        }
    }
}
